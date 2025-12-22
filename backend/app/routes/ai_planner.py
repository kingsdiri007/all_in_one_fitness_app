from flask import Blueprint, request, jsonify
from app import db
from app.models import User, UserSchedule, CalendarEvent, WorkoutTemplate
from flask_jwt_extended import jwt_required, get_jwt_identity
import requests
from datetime import datetime, timedelta
import os

ai_planner_bp = Blueprint('ai_planner', __name__, url_prefix='/api/ai-planner')

# n8n webhook URL (configure in .env)
N8N_WEBHOOK_URL = os.getenv('N8N_WEBHOOK_URL', 'http://localhost:5678/webhook/generate-workout-plan')


@ai_planner_bp.route('/generate', methods=['POST'])
@jwt_required()
def generate_workout_plan():
    """
    Request AI to generate a personalized weekly workout plan
    User provides: available days, time slots, fitness goal, duration
    """
    user_id = get_jwt_identity()
    user = User.query.get_or_404(user_id)
    data = request.get_json()
    
    # Validation
    required_fields = ['available_days', 'sessions_per_week']
    if not all(field in data for field in required_fields):
        return jsonify({'error': 'Missing required fields'}), 400
    
    try:
        # Create schedule record
        schedule = UserSchedule(
            user_id=user_id,
            available_days=data['available_days'],
            available_time_slots=data.get('available_time_slots', {}),
            sessions_per_week=data['sessions_per_week'],
            session_duration=data.get('session_duration', 60),
            generation_status='processing'
        )
        db.session.add(schedule)
        db.session.commit()
        
        # Prepare payload for n8n
        payload = {
            'user_id': user_id,
            'schedule_id': schedule.id,
            'user_data': {
                'age': user.age,
                'weight': user.weight,
                'height': user.height,
                'gender': user.gender,
                'fitness_goal': user.fitness_goal
            },
            'preferences': {
                'available_days': data['available_days'],
                'available_time_slots': data.get('available_time_slots', {}),
                'sessions_per_week': data['sessions_per_week'],
                'session_duration': data.get('session_duration', 60),
                'equipment_access': data.get('equipment_access', ['bodyweight', 'dumbbell', 'barbell']),
                'experience_level': data.get('experience_level', 'beginner')
            },
            'callback_url': f"{request.host_url}api/ai-planner/webhook/plan-ready"
        }
        
        # Trigger n8n workflow
        response = requests.post(
            N8N_WEBHOOK_URL,
            json=payload,
        timeout=300
        )
        
        if response.status_code == 200:
            n8n_response = response.json()
            schedule.n8n_workflow_id = n8n_response.get('workflow_id')
            db.session.commit()
            
            return jsonify({
                'message': 'AI workout plan generation started',
                'schedule_id': schedule.id,
                'status': 'processing',
                'estimated_time': '30-60 seconds'
            }), 202
        else:
            schedule.generation_status = 'failed'
            db.session.commit()
            return jsonify({'error': 'Failed to trigger n8n workflow'}), 500
            
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to generate plan', 'details': str(e)}), 500


@ai_planner_bp.route('/webhook/plan-ready', methods=['POST'])
def receive_generated_plan():
    """
    Webhook endpoint for n8n to send the generated workout plan
    n8n will call this after AI generates the plan
    """
    data = request.get_json()
    
    if not data or not data.get('schedule_id') or not data.get('weekly_plan'):
        return jsonify({'error': 'Invalid payload'}), 400
    
    schedule_id = data['schedule_id']
    schedule = UserSchedule.query.get(schedule_id)
    
    if not schedule:
        return jsonify({'error': 'Schedule not found'}), 404
    
    try:
        # Save the AI-generated plan
        schedule.weekly_plan = data['weekly_plan']
        schedule.generation_status = 'completed'
        db.session.commit()
        
        # Create calendar events from the plan
        create_calendar_events_from_plan(schedule, data['weekly_plan'])
        
        return jsonify({
            'message': 'Plan received and saved',
            'schedule_id': schedule_id
        }), 200
        
    except Exception as e:
        schedule.generation_status = 'failed'
        db.session.commit()
        return jsonify({'error': 'Failed to save plan', 'details': str(e)}), 500


def create_calendar_events_from_plan(schedule, weekly_plan):
    """
    Convert AI-generated weekly plan into calendar events
    
    Expected weekly_plan format:
    {
        "monday": {
            "workout": "Push Day",
            "time": "morning",
            "exercises": [...],
            "duration": 60
        },
        ...
    }
    """
    user = schedule.user
    today = datetime.utcnow().date()
    
    # Map day names to numbers (0=Monday)
    day_mapping = {
        'monday': 0, 'tuesday': 1, 'wednesday': 2, 'thursday': 3,
        'friday': 4, 'saturday': 5, 'sunday': 6
    }
    
    # Time slot mapping
    time_slots = {
        'morning': ('08:00', '09:00'),
        'afternoon': ('14:00', '15:00'),
        'evening': ('18:00', '19:00')
    }
    
    for day_name, workout_info in weekly_plan.items():
        if day_name.lower() not in day_mapping:
            continue
        
        # Calculate next occurrence of this day
        target_day = day_mapping[day_name.lower()]
        days_ahead = target_day - today.weekday()
        if days_ahead <= 0:
            days_ahead += 7
        
        event_date = today + timedelta(days=days_ahead)
        
        # Get time slot
        time_slot = workout_info.get('time', 'morning')
        start_time_str, end_time_str = time_slots.get(time_slot, ('08:00', '09:00'))
        
        # Create calendar event
        event = CalendarEvent(
            user_id=user.id,
            schedule_id=schedule.id,
            title=workout_info.get('workout', 'Workout Session'),
            description=workout_info.get('description', ''),
            date=event_date,
            start_time=datetime.strptime(start_time_str, '%H:%M').time(),
            end_time=datetime.strptime(end_time_str, '%H:%M').time(),
            duration_minutes=workout_info.get('duration', 60),
            exercises=workout_info.get('exercises', [])
        )
        db.session.add(event)
    
    db.session.commit()


@ai_planner_bp.route('/status/<int:schedule_id>', methods=['GET'])
@jwt_required()
def get_generation_status(schedule_id):
    """Check status of AI plan generation"""
    user_id = get_jwt_identity()
    
    schedule = UserSchedule.query.filter_by(
        id=schedule_id,
        user_id=user_id
    ).first_or_404()
    
    return jsonify({
        'schedule': schedule.to_dict(),
        'status': schedule.generation_status
    }), 200


@ai_planner_bp.route('/my-plans', methods=['GET'])
@jwt_required()
def get_my_plans():
    """Get all AI-generated plans for user"""
    user_id = get_jwt_identity()
    
    schedules = UserSchedule.query.filter_by(user_id=user_id)\
        .order_by(UserSchedule.generated_at.desc())\
        .all()
    
    return jsonify({
        'plans': [s.to_dict() for s in schedules]
    }), 200


@ai_planner_bp.route('/activate/<int:schedule_id>', methods=['PATCH'])
@jwt_required()
def activate_plan(schedule_id):
    """Activate a specific workout plan"""
    user_id = get_jwt_identity()
    
    # Deactivate all other plans
    UserSchedule.query.filter_by(user_id=user_id).update({'is_active': False})
    
    # Activate this one
    schedule = UserSchedule.query.filter_by(
        id=schedule_id,
        user_id=user_id
    ).first_or_404()
    
    schedule.is_active = True
    db.session.commit()
    
    return jsonify({
        'message': 'Plan activated',
        'schedule': schedule.to_dict()
    }), 200