from flask import Blueprint, request, jsonify
from app import db
from app.models import User
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from datetime import timedelta
import re

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')

# Constants for validation
VALID_FITNESS_GOALS = [
    "Lose Weight",
    "Build Muscle",
    "Get Fit",
    "Improve Endurance"
]

VALID_DIFFICULTIES = ["Beginner", "Intermediate", "Advanced"]


VALID_TUNISIAN_CITIES = [
    "Tunis", "Sfax", "Sousse", "Kairouan", "Bizerte", "Gabès", "Ariana", 
    "Gafsa", "Monastir", "Ben Arous", "Kasserine", "Médenine", "Nabeul", 
    "Tataouine", "Béja", "Jendouba", "Mahdia", "Sidi Bouzid", "Zaghouan", 
    "Siliana", "Kébili", "Tozeur", "Manouba", "Kef"
]

def validate_email(email):
    """Validate email format"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None


@auth_bp.route('/register', methods=['POST'])
def register():
    """Register a new user with comprehensive validation"""
    data = request.get_json()
    
    if not data:
        return jsonify({
            'success': False,
            'error': 'No data provided'
        }), 400
    
    # ========== VALIDATION ==========
    
    # Required fields
    required_fields = [
        'first_name', 'last_name', 'email', 'password', 
        'fitness_goal', 'weight', 'goal_weight',
        'height', 'estimated_daily_steps', 
        'workout_difficulty', 'location'
    ]
    
    for field in required_fields:
        if field not in data or data[field] is None or data[field] == '':
            return jsonify({
                'success': False,
                'error': f'Missing required field: {field}'
            }), 400
    
    # Email validation
    email = data['email'].strip().lower()
    if not validate_email(email):
        return jsonify({
            'success': False,
            'error': 'Invalid email format'
        }), 400
    
    # Check if email already exists
    if User.query.filter_by(email=email).first():
        return jsonify({
            'success': False,
            'error': 'Email already exists'
        }), 400
    
    # Password validation
    password = data['password']
    if len(password) < 8:
        return jsonify({
            'success': False,
            'error': 'Password must be at least 8 characters'
        }), 400
    
    # Fitness goal validation
    fitness_goal = data['fitness_goal']
    if fitness_goal not in VALID_FITNESS_GOALS:
        return jsonify({
            'success': False,
            'error': f'Invalid fitness goal. Must be one of: {", ".join(VALID_FITNESS_GOALS)}'
        }), 400
    
    
    
    # Workout difficulty validation
    workout_difficulty = data['workout_difficulty']
    if workout_difficulty not in VALID_DIFFICULTIES:
        return jsonify({
            'success': False,
            'error': 'workout_difficulty must be "Beginner", "Intermediate", or "Advanced"'
        }), 400
    
    # Location validation
    location = data['location']
    if location not in VALID_TUNISIAN_CITIES:
        return jsonify({
            'success': False,
            'error': 'Invalid location - must be a Tunisian city'
        }), 400
    
    # Numeric field validations
    try:
        weight = float(data['weight'])
        goal_weight = float(data['goal_weight'])
        height = float(data['height'])
        estimated_daily_steps = int(data['estimated_daily_steps'])
        
        if weight <= 0:
            return jsonify({
                'success': False,
                'error': 'weight must be a positive number'
            }), 400
        
        if goal_weight <= 0:
            return jsonify({
                'success': False,
                'error': 'goal_weight must be a positive number'
            }), 400
        
        if height <= 0:
            return jsonify({
                'success': False,
                'error': 'height must be a positive number'
            }), 400
        
        if estimated_daily_steps < 0:
            return jsonify({
                'success': False,
                'error': 'estimated_daily_steps must be 0 or positive'
            }), 400
            
    except (ValueError, TypeError):
        return jsonify({
            'success': False,
            'error': 'Invalid numeric value for weight, goal_weight, height, or estimated_daily_steps'
        }), 400
    
    # ========== CREATE USER ==========
    
    try:
        user = User(
            email=email,
            first_name=data['first_name'].strip(),
            last_name=data['last_name'].strip(),
            age=data.get('age'),
            weight=weight,
            goal_weight=goal_weight,
            height=height,
            gender=data.get('gender'),
            fitness_goal=fitness_goal,
            estimated_daily_steps=estimated_daily_steps,
            workout_difficulty=workout_difficulty,
            location=location
        )
        user.set_password(password)
        
        db.session.add(user)
        db.session.commit()
        
        # Generate token
        access_token = create_access_token(
            identity=user.id,
            expires_delta=timedelta(days=7)
        )
        
        return jsonify({
            'success': True,
            'message': 'Registration successful',
            'user': {
                'id': user.id,
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name
            },
            'access_token': access_token
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': 'Registration failed',
            'details': str(e)
        }), 500


@auth_bp.route('/login', methods=['POST'])
def login():
    """Login user"""
    data = request.get_json()
    
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({
            'success': False,
            'error': 'Email and password are required'
        }), 400
    
    user = User.query.filter_by(email=data['email'].strip().lower()).first()
    
    if not user or not user.check_password(data['password']):
        return jsonify({
            'success': False,
            'error': 'Invalid email or password'
        }), 401
    
    access_token = create_access_token(
        identity=user.id,
        expires_delta=timedelta(days=7)
    )
    
    return jsonify({
        'success': True,
        'message': 'Login successful',
        'user': user.to_dict(),
        'access_token': access_token
    }), 200


@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def get_current_user():
    """Get current logged-in user"""
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


@auth_bp.route('/validate/email', methods=['POST'])
def validate_email_endpoint():
    """Check if email is available"""
    data = request.get_json()
    
    if not data or not data.get('email'):
        return jsonify({
            'success': False,
            'error': 'Email is required'
        }), 400
    
    email = data['email'].strip().lower()
    
    # Check format
    if not validate_email(email):
        return jsonify({
            'success': False,
            'available': False,
            'error': 'Invalid email format'
        }), 200
    
    # Check if exists
    exists = User.query.filter_by(email=email).first() is not None
    
    return jsonify({
        'success': True,
        'available': not exists,
        'message': 'Email already exists' if exists else 'Email is available'
    }), 200