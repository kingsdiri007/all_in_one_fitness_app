from flask import Blueprint, request, jsonify
from app import db
from app.models import (
    User, WorkoutSession, SessionExercise, 
    WeightHistory, ExercisePersonalRecord
)
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime, timedelta
from sqlalchemy import func

progress_bp = Blueprint('progress', __name__, url_prefix='/api/progress')


@progress_bp.route('/dashboard', methods=['GET'])
@jwt_required()
def get_dashboard():
    """Get user's fitness dashboard with all stats"""
    user_id = get_jwt_identity()
    user = User.query.get_or_404(user_id)
    
    # Workout stats
    workout_stats = user.get_workout_stats()
    
    # Recent weight entries (last 10)
    recent_weights = WeightHistory.query.filter_by(user_id=user_id)\
        .order_by(WeightHistory.recorded_at.desc())\
        .limit(10)\
        .all()
    
    # Personal records (top 5 most recent)
    recent_prs = ExercisePersonalRecord.query.filter_by(user_id=user_id)\
        .order_by(ExercisePersonalRecord.achieved_at.desc())\
        .limit(5)\
        .all()
    
    # This week's workouts
    week_start = datetime.utcnow() - timedelta(days=7)
    this_week_workouts = WorkoutSession.query.filter(
        WorkoutSession.user_id == user_id,
        WorkoutSession.created_at >= week_start,
        WorkoutSession.completed == True
    ).count()
    
    return jsonify({
        'user': user.to_dict(),
        'workout_stats': workout_stats,
        'this_week_workouts': this_week_workouts,
        'recent_weight': [w.to_dict() for w in recent_weights],
        'recent_prs': [pr.to_dict() for pr in recent_prs]
    }), 200


@progress_bp.route('/weight', methods=['GET'])
@jwt_required()
def get_weight_history():
    """Get user's weight history"""
    user_id = get_jwt_identity()
    
    limit = request.args.get('limit', default=30, type=int)
    
    weights = WeightHistory.query.filter_by(user_id=user_id)\
        .order_by(WeightHistory.recorded_at.desc())\
        .limit(limit)\
        .all()
    
    return jsonify({
        'weight_history': [w.to_dict() for w in weights]
    }), 200


@progress_bp.route('/weight', methods=['POST'])
@jwt_required()
def log_weight():
    """Log a new weight entry"""
    user_id = get_jwt_identity()
    user = User.query.get_or_404(user_id)
    data = request.get_json()
    
    if not data or not data.get('weight'):
        return jsonify({'error': 'weight is required'}), 400
    
    try:
        weight_entry = WeightHistory(
            user_id=user_id,
            weight=data['weight'],
            notes=data.get('notes')
        )
        db.session.add(weight_entry)
        
        # Update user's current weight
        user.weight = data['weight']
        
        db.session.commit()
        
        return jsonify({
            'message': 'Weight logged successfully',
            'entry': weight_entry.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to log weight', 'details': str(e)}), 500


@progress_bp.route('/personal-records', methods=['GET'])
@jwt_required()
def get_personal_records():
    """Get all user's personal records"""
    user_id = get_jwt_identity()
    
    # Get latest PR for each exercise
    subquery = db.session.query(
        ExercisePersonalRecord.exercise_id,
        func.max(ExercisePersonalRecord.weight).label('max_weight')
    ).filter_by(user_id=user_id).group_by(ExercisePersonalRecord.exercise_id).subquery()
    
    prs = db.session.query(ExercisePersonalRecord).join(
        subquery,
        (ExercisePersonalRecord.exercise_id == subquery.c.exercise_id) &
        (ExercisePersonalRecord.weight == subquery.c.max_weight)
    ).filter(ExercisePersonalRecord.user_id == user_id).all()
    
    return jsonify({
        'personal_records': [pr.to_dict() for pr in prs]
    }), 200


@progress_bp.route('/personal-records', methods=['POST'])
@jwt_required()
def log_personal_record():
    """Log a new personal record"""
    user_id = get_jwt_identity()
    data = request.get_json()
    
    if not data or not data.get('exercise_id') or not data.get('weight') or not data.get('reps'):
        return jsonify({'error': 'exercise_id, weight, and reps are required'}), 400
    
    try:
        # Check if this is actually a PR
        existing_pr = ExercisePersonalRecord.query.filter_by(
            user_id=user_id,
            exercise_id=data['exercise_id']
        ).order_by(ExercisePersonalRecord.weight.desc()).first()
        
        if existing_pr and existing_pr.weight >= data['weight']:
            return jsonify({
                'error': 'Not a personal record',
                'current_pr': existing_pr.to_dict()
            }), 400
        
        pr = ExercisePersonalRecord(
            user_id=user_id,
            exercise_id=data['exercise_id'],
            weight=data['weight'],
            reps=data['reps']
        )
        db.session.add(pr)
        db.session.commit()
        
        return jsonify({
            'message': 'Personal record achieved! 🎉',
            'pr': pr.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to log PR', 'details': str(e)}), 500


@progress_bp.route('/workout-history', methods=['GET'])
@jwt_required()
def get_workout_history():
    """Get user's workout history with filters"""
    user_id = get_jwt_identity()
    
    # Query params for filtering
    limit = request.args.get('limit', default=20, type=int)
    completed_only = request.args.get('completed', default='true').lower() == 'true'
    
    query = WorkoutSession.query.filter_by(user_id=user_id)
    
    if completed_only:
        query = query.filter_by(completed=True)
    
    sessions = query.order_by(WorkoutSession.created_at.desc())\
        .limit(limit)\
        .all()
    
    return jsonify({
        'workout_history': [s.to_dict() for s in sessions]
    }), 200


@progress_bp.route('/streak', methods=['GET'])
@jwt_required()
def get_workout_streak():
    """Calculate user's current workout streak"""
    user_id = get_jwt_identity()
    
    # Get all completed workouts ordered by date
    workouts = WorkoutSession.query.filter_by(
        user_id=user_id,
        completed=True
    ).order_by(WorkoutSession.completed_at.desc()).all()
    
    if not workouts:
        return jsonify({
            'current_streak': 0,
            'longest_streak': 0,
            'message': 'Start your first workout!'
        }), 200
    
    # Calculate current streak
    current_streak = 0
    today = datetime.utcnow().date()
    check_date = today
    
    for workout in workouts:
        workout_date = workout.completed_at.date()
        
        # If workout is on check_date or previous day
        if workout_date == check_date or workout_date == check_date - timedelta(days=1):
            current_streak += 1
            check_date = workout_date - timedelta(days=1)
        else:
            break
    
    return jsonify({
        'current_streak': current_streak,
        'last_workout': workouts[0].completed_at.isoformat(),
        'total_workouts': len(workouts)
    }), 200


@progress_bp.route('/stats/monthly', methods=['GET'])
@jwt_required()
def get_monthly_stats():
    """Get workout stats for current month"""
    user_id = get_jwt_identity()
    
    # First day of current month
    today = datetime.utcnow()
    month_start = today.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    
    # Workouts this month
    monthly_workouts = WorkoutSession.query.filter(
        WorkoutSession.user_id == user_id,
        WorkoutSession.created_at >= month_start,
        WorkoutSession.completed == True
    ).all()
    
    # Total exercises completed
    total_exercises = sum(
        len([ex for ex in w.exercises if ex.completed])
        for w in monthly_workouts
    )
    
    # Total sets completed
    total_sets = sum(
        sum(ex.sets for ex in w.exercises if ex.completed)
        for w in monthly_workouts
    )
    
    return jsonify({
        'month': today.strftime('%B %Y'),
        'workouts_completed': len(monthly_workouts),
        'total_exercises': total_exercises,
        'total_sets': total_sets,
        'workouts': [w.to_dict() for w in monthly_workouts]
    }), 200