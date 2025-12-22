from datetime import datetime
from flask import Blueprint, request, jsonify
from app import db
from app.models import Exercise, SessionExercise, WorkoutSession, WorkoutTemplate, WorkoutExercise, UserWorkout
from flask_jwt_extended import jwt_required, get_jwt_identity
from random import sample, shuffle
workouts_bp = Blueprint("workouts", __name__, url_prefix="/api/workouts")


@workouts_bp.route("/exercises", methods=["GET"])
def get_exercises():
    """Get all available exercises"""
    exercises = Exercise.query.all()
    return jsonify({
        'exercises': [e.to_dict() for e in exercises]
    }), 200


@workouts_bp.route("/templates", methods=["GET"])
def get_workout_templates():
    """Get all workout templates"""
    goal = request.args.get('goal')  # Optional filter by goal
    level = request.args.get('level')  # Optional filter by level
    
    query = WorkoutTemplate.query
    
    if goal:
        query = query.filter_by(goal=goal)
    if level:
        query = query.filter_by(level=level)
    
    templates = query.all()
    
    return jsonify({
        'templates': [t.to_dict() for t in templates]
    }), 200
@workouts_bp.route("/templates/<int:template_id>/generate", methods=["GET"])
@jwt_required()
def generate_dynamic_workout(template_id):
    """Generate a randomized workout from template's exercise pool"""
    template = WorkoutTemplate.query.get_or_404(template_id)
    
    # Get number of exercises to include (from query param or default)
    num_exercises = request.args.get('count', default=5, type=int)
    num_exercises = min(num_exercises, len(template.exercises))  # Don't exceed available
    
    if not template.exercises:
        return jsonify({'error': 'Template has no exercises'}), 400
    
    # Randomly select exercises
    selected = sample(template.exercises, num_exercises)
    
    # Shuffle the order for variety
    shuffle(selected)
    
    # Build response with new random order
    exercises_data = []
    for idx, we in enumerate(selected, start=1):
        ex_data = we.to_dict()
        ex_data['order'] = idx  # Override with new random order
        exercises_data.append(ex_data)
    
    return jsonify({
        'template': {
            'id': template.id,
            'name': template.name,
            'description': template.description,
            'goal': template.goal,
            'level': template.level
        },
        'exercises': exercises_data,
        'generated_at': datetime.utcnow().isoformat()
    }), 200

@workouts_bp.route("/my-workouts", methods=["GET"])
@jwt_required()
def get_my_workouts():
    """Get user's assigned workouts"""
    user_id = get_jwt_identity()
    
    user_workouts = UserWorkout.query.filter_by(
        user_id=user_id,
        is_active=True
    ).all()
    
    return jsonify({
        'workouts': [uw.to_dict() for uw in user_workouts]
    }), 200


@workouts_bp.route("/my-workouts", methods=["POST"])
@jwt_required()
def assign_workout():
    """Assign a workout template to current user"""
    user_id = get_jwt_identity()
    data = request.get_json()
    
    if not data or not data.get('template_id'):
        return jsonify({'error': 'template_id is required'}), 400
    
    # Check if template exists
    template = WorkoutTemplate.query.get(data['template_id'])
    if not template:
        return jsonify({'error': 'Template not found'}), 404
    
    # Check if already assigned
    existing = UserWorkout.query.filter_by(
        user_id=user_id,
        template_id=data['template_id'],
        is_active=True
    ).first()
    
    if existing:
        return jsonify({'error': 'Workout already assigned'}), 409
    
    try:
        user_workout = UserWorkout(
            user_id=user_id,
            template_id=data['template_id']
        )
        db.session.add(user_workout)
        db.session.commit()
        
        return jsonify({
            'message': 'Workout assigned successfully',
            'workout': user_workout.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to assign workout', 'details': str(e)}), 500


@workouts_bp.route("/my-workouts/<int:workout_id>", methods=["DELETE"])
@jwt_required()
def remove_workout(workout_id):
    """Remove a workout from user's list"""
    user_id = get_jwt_identity()
    
    user_workout = UserWorkout.query.filter_by(
        id=workout_id,
        user_id=user_id
    ).first()
    
    if not user_workout:
        return jsonify({'error': 'Workout not found'}), 404
    
    try:
        user_workout.is_active = False
        db.session.commit()
        
        return jsonify({'message': 'Workout removed successfully'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to remove workout', 'details': str(e)}), 500
@workouts_bp.route("/sessions", methods=["POST"])
@jwt_required()
def create_workout_session():
    """Create a new workout session with random exercises"""
    user_id = get_jwt_identity()
    data = request.get_json()
    
    if not data or not data.get('template_id'):
        return jsonify({'error': 'template_id is required'}), 400
    
    template = WorkoutTemplate.query.get(data['template_id'])
    if not template:
        return jsonify({'error': 'Template not found'}), 404
    
    # Get number of exercises (default 5)
    num_exercises = data.get('exercise_count', 5)
    num_exercises = min(num_exercises, len(template.exercises))
    
    # Random selection
    selected = sample(template.exercises, num_exercises)
    shuffle(selected)
    
    try:
        # Create session
        session = WorkoutSession(
            user_id=user_id,
            template_id=template.id
        )
        db.session.add(session)
        db.session.flush()  # Get session.id
        
        # Add exercises to session
        for idx, we in enumerate(selected, start=1):
            session_exercise = SessionExercise(
                session_id=session.id,
                exercise_id=we.exercise_id,
                sets=we.sets,
                reps=we.reps,
                rest_seconds=we.rest_seconds,
                order=idx
            )
            db.session.add(session_exercise)
        
        db.session.commit()
        
        return jsonify({
            'message': 'Workout session created',
            'session': session.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to create session', 'details': str(e)}), 500


@workouts_bp.route("/sessions", methods=["GET"])
@jwt_required()
def get_my_sessions():
    """Get user's workout sessions history"""
    user_id = get_jwt_identity()
    
    sessions = WorkoutSession.query.filter_by(user_id=user_id)\
        .order_by(WorkoutSession.created_at.desc())\
        .all()
    
    return jsonify({
        'sessions': [s.to_dict() for s in sessions]
    }), 200


@workouts_bp.route("/sessions/<int:session_id>", methods=["GET"])
@jwt_required()
def get_session_detail(session_id):
    """Get specific workout session details"""
    user_id = get_jwt_identity()
    
    session = WorkoutSession.query.filter_by(
        id=session_id,
        user_id=user_id
    ).first_or_404()
    
    return jsonify({
        'session': session.to_dict()
    }), 200


@workouts_bp.route("/sessions/<int:session_id>/complete", methods=["PATCH"])
@jwt_required()
def complete_workout_session(session_id):
    """Mark a workout session as completed"""
    user_id = get_jwt_identity()
    
    session = WorkoutSession.query.filter_by(
        id=session_id,
        user_id=user_id
    ).first_or_404()
    
    if session.completed:
        return jsonify({'error': 'Session already completed'}), 400
    
    try:
        session.completed = True
        session.completed_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'message': 'Workout completed!',
            'session': session.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to complete session', 'details': str(e)}), 500


@workouts_bp.route("/sessions/<int:session_id>/exercises/<int:exercise_id>", methods=["PATCH"])
@jwt_required()
def update_session_exercise(session_id, exercise_id):
    """Update exercise performance (weight, reps completed)"""
    user_id = get_jwt_identity()
    data = request.get_json()
    
    session = WorkoutSession.query.filter_by(
        id=session_id,
        user_id=user_id
    ).first_or_404()
    
    session_exercise = SessionExercise.query.filter_by(
        session_id=session_id,
        id=exercise_id
    ).first_or_404()
    
    try:
        if 'weight_used' in data:
            session_exercise.weight_used = data['weight_used']
        if 'actual_reps' in data:
            session_exercise.actual_reps = data['actual_reps']
        if 'completed' in data:
            session_exercise.completed = data['completed']
        
        db.session.commit()
        
        return jsonify({
            'message': 'Exercise updated',
            'exercise': session_exercise.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to update exercise', 'details': str(e)}), 500