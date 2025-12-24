from flask import Blueprint, request, jsonify
from app import db
from app.models import User
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy.exc import IntegrityError

users_bp = Blueprint('users', __name__, url_prefix='/api/users')

# Constants
VALID_FITNESS_GOALS = ["Lose Weight", "Build Muscle", "Get Fit", "Improve Endurance"]
VALID_DIFFICULTIES = ["Beginner", "Intermediate", "Advanced"]
VALID_TUNISIAN_CITIES = [
    "Tunis", "Sfax", "Sousse", "Kairouan", "Bizerte", "Gabès", "Ariana", 
    "Gafsa", "Monastir", "Ben Arous", "Kasserine", "Médenine", "Nabeul", 
    "Tataouine", "Béja", "Jendouba", "Mahdia", "Sidi Bouzid", "Zaghouan", 
    "Siliana", "Kébili", "Tozeur", "Manouba", "Kef"
]


@users_bp.route('/me', methods=['GET'])
@jwt_required()
def get_profile():
    """Get current user profile"""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({
            'success': False,
            'error': 'User not found'
        }), 404
    
    return jsonify({
        'success': True,
        'user': user.to_dict()
    }), 200


@users_bp.route('/me', methods=['PUT'])
@jwt_required()
def update_profile():
    """Update user profile"""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({
            'success': False,
            'error': 'User not found'
        }), 404
    
    data = request.get_json()
    
    if not data:
        return jsonify({
            'success': False,
            'error': 'No data provided'
        }), 400
    
    # Validate and update fields
    try:
        if 'first_name' in data:
            user.first_name = data['first_name'].strip()
        
        if 'last_name' in data:
            user.last_name = data['last_name'].strip()
        
        if 'age' in data:
            user.age = int(data['age'])
        
        if 'weight' in data:
            weight = float(data['weight'])
            if weight <= 0:
                return jsonify({'success': False, 'error': 'weight must be positive'}), 400
            user.weight = weight
        
       
        
        if 'goal_weight' in data:
            goal_weight = float(data['goal_weight'])
            if goal_weight <= 0:
                return jsonify({'success': False, 'error': 'goal_weight must be positive'}), 400
            user.goal_weight = goal_weight
        
        if 'height' in data:
            height = float(data['height'])
            if height <= 0:
                return jsonify({'success': False, 'error': 'height must be positive'}), 400
            user.height = height
        
        if 'gender' in data:
            user.gender = data['gender']
        
        if 'fitness_goal' in data:
            if data['fitness_goal'] not in VALID_FITNESS_GOALS:
                return jsonify({'success': False, 'error': 'Invalid fitness_goal'}), 400
            user.fitness_goal = data['fitness_goal']
        
        if 'estimated_daily_steps' in data:
            steps = int(data['estimated_daily_steps'])
            if steps < 0:
                return jsonify({'success': False, 'error': 'estimated_daily_steps must be >= 0'}), 400
            user.estimated_daily_steps = steps
        
        if 'workout_difficulty' in data:
            if data['workout_difficulty'] not in VALID_DIFFICULTIES:
                return jsonify({'success': False, 'error': 'Invalid workout_difficulty'}), 400
            user.workout_difficulty = data['workout_difficulty']
        
        if 'location' in data:
            if data['location'] not in VALID_TUNISIAN_CITIES:
                return jsonify({'success': False, 'error': 'Invalid location'}), 400
            user.location = data['location']
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Profile updated successfully',
            'user': user.to_dict()
        }), 200
        
    except ValueError as e:
        return jsonify({
            'success': False,
            'error': 'Invalid data type',
            'details': str(e)
        }), 400
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': 'Update failed',
            'details': str(e)
        }), 500


@users_bp.route('/password', methods=['PATCH'])
@jwt_required()
def change_password():
    """Change user password"""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({
            'success': False,
            'error': 'User not found'
        }), 404
    
    data = request.get_json()
    
    if not data or not data.get('current_password') or not data.get('new_password'):
        return jsonify({
            'success': False,
            'error': 'Current password and new password are required'
        }), 400
    
    if not user.check_password(data['current_password']):
        return jsonify({
            'success': False,
            'error': 'Current password is incorrect'
        }), 401
    
    if len(data['new_password']) < 8:
        return jsonify({
            'success': False,
            'error': 'New password must be at least 8 characters'
        }), 400
    
    try:
        user.set_password(data['new_password'])
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Password changed successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': 'Password change failed',
            'details': str(e)
        }), 500


@users_bp.route('/me', methods=['DELETE'])
@jwt_required()
def delete_account():
    """Delete user account"""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({
            'success': False,
            'error': 'User not found'
        }), 404
    
    data = request.get_json()
    
    if not data or not data.get('password'):
        return jsonify({
            'success': False,
            'error': 'Password confirmation required'
        }), 400
    
    if not user.check_password(data['password']):
        return jsonify({
            'success': False,
            'error': 'Incorrect password'
        }), 401
    
    try:
        db.session.delete(user)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Account deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': 'Account deletion failed',
            'details': str(e)
        }), 500