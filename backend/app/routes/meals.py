from flask import Blueprint, request, jsonify
from app import db
from app.models import Food, Meal, MealItem, DailyMealPlan, User, MealSchedule
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime, date
import requests
import os
import json

meals_bp = Blueprint('meals', __name__, url_prefix='/api/meals')

# ========== FOODS ==========

@meals_bp.route('/foods', methods=['GET'])
def get_foods():
    """Get all foods with optional filters"""
    category = request.args.get('category')
    common_only = request.args.get('common', 'false').lower() == 'true'
    
    query = Food.query
    
    if category:
        query = query.filter_by(category=category)
    if common_only:
        query = query.filter_by(is_common=True)
    
    foods = query.order_by(Food.name).all()
    
    return jsonify({
        'foods': [f.to_dict() for f in foods],
        'count': len(foods)
    }), 200


@meals_bp.route('/foods/<int:food_id>', methods=['GET'])
def get_food(food_id):
    """Get specific food details"""
    food = Food.query.get_or_404(food_id)
    return jsonify({'food': food.to_dict()}), 200


@meals_bp.route('/foods/categories', methods=['GET'])
def get_food_categories():
    """Get list of food categories"""
    categories = db.session.query(Food.category).distinct().all()
    return jsonify({
        'categories': [c[0] for c in categories]
    }), 200


# ========== MEALS ==========

@meals_bp.route('/', methods=['GET'])
def get_meals():
    """Get all meals with optional filters"""
    meal_type = request.args.get('type')
    goal = request.args.get('goal')
    
    query = Meal.query
    
    if meal_type:
        query = query.filter_by(meal_type=meal_type)
    if goal:
        query = query.filter_by(goal=goal)
    
    meals = query.order_by(Meal.meal_type, Meal.name).all()
    return jsonify({
        'meals': [m.to_dict() for m in meals],
        'count': len(meals)
    }), 200


@meals_bp.route('/<int:meal_id>', methods=['GET'])
def get_meal(meal_id):
    """Get specific meal with all items and nutrition details"""
    meal = Meal.query.get_or_404(meal_id)
    return jsonify({'meal': meal.to_dict(include_items=True)}), 200


@meals_bp.route('/', methods=['POST'])
@jwt_required()
def create_meal():
    """Create a new meal"""
    data = request.get_json()
    
    if not data.get('name') or not data.get('meal_type'):
        return jsonify({'error': 'Name and meal_type are required'}), 400
    
    if not data.get('items') or len(data['items']) == 0:
        return jsonify({'error': 'Meal must have at least one item'}), 400
    
    meal = Meal(
        name=data['name'],
        meal_type=data['meal_type'],
        goal=data.get('goal'),
        description=data.get('description')
    )
    db.session.add(meal)
    db.session.flush()
    
    for item_data in data['items']:
        food_id = item_data.get('food_id')
        quantity = item_data.get('quantity')
        
        if not food_id or not quantity:
            db.session.rollback()
            return jsonify({'error': 'Each item must have food_id and quantity'}), 400
        
        food = Food.query.get(food_id)
        if not food:
            db.session.rollback()
            return jsonify({'error': f'Food with id {food_id} not found'}), 404
        
        if quantity < 1 or quantity > 1000:
            db.session.rollback()
            return jsonify({'error': f'Quantity must be between 1-1000g'}), 400
        
        item = MealItem(
            meal_id=meal.id,
            food_id=food_id,
            quantity=quantity
        )
        db.session.add(item)
    
    db.session.flush()
    meal.calculate_totals()
    db.session.commit()
    
    return jsonify({
        'message': 'Meal created successfully',
        'meal': meal.to_dict(include_items=True)
    }), 201


@meals_bp.route('/<int:meal_id>', methods=['PUT'])
@jwt_required()
def update_meal(meal_id):
    """Update an existing meal"""
    meal = Meal.query.get_or_404(meal_id)
    data = request.get_json()
    
    if 'name' in data:
        meal.name = data['name']
    if 'meal_type' in data:
        meal.meal_type = data['meal_type']
    if 'goal' in data:
        meal.goal = data['goal']
    if 'description' in data:
        meal.description = data['description']
    
    if 'items' in data:
        MealItem.query.filter_by(meal_id=meal.id).delete()
        
        for item_data in data['items']:
            food_id = item_data.get('food_id')
            quantity = item_data.get('quantity')
            
            if not food_id or not quantity:
                db.session.rollback()
                return jsonify({'error': 'Each item must have food_id and quantity'}), 400
            
            food = Food.query.get(food_id)
            if not food:
                db.session.rollback()
                return jsonify({'error': f'Food with id {food_id} not found'}), 404
            
            if quantity < 1 or quantity > 1000:
                db.session.rollback()
                return jsonify({'error': f'Quantity must be between 1-1000g'}), 400
            
            item = MealItem(
                meal_id=meal.id,
                food_id=food_id,
                quantity=quantity
            )
            db.session.add(item)
        
        db.session.flush()
        meal.calculate_totals()
    
    db.session.commit()
    
    return jsonify({
        'message': 'Meal updated successfully',
        'meal': meal.to_dict(include_items=True)
    }), 200


@meals_bp.route('/<int:meal_id>', methods=['DELETE'])
@jwt_required()
def delete_meal(meal_id):
    """Delete a meal"""
    meal = Meal.query.get_or_404(meal_id)
    
    db.session.delete(meal)
    db.session.commit()
    
    return jsonify({'message': 'Meal deleted successfully'}), 200


@meals_bp.route('/recommended', methods=['GET'])
def get_recommended_meals():
    """Get recommended meals based on goal and meal type"""
    goal = request.args.get('goal')
    meal_type = request.args.get('type')
    
    if not goal:
        return jsonify({'error': 'Goal parameter is required'}), 400
    
    query = Meal.query.filter_by(goal=goal)
    
    if meal_type:
        query = query.filter_by(meal_type=meal_type)
    
    meals = query.all()
    
    return jsonify({
        'meals': [m.to_dict(include_items=True) for m in meals],
        'count': len(meals),
        'filters': {
            'goal': goal,
            'meal_type': meal_type
        }
    }), 200


# ========== DAILY MEAL PLANS ==========

@meals_bp.route('/plans', methods=['GET'])
@jwt_required()
def get_meal_plans():
    """Get user's meal plans"""
    user_id = get_jwt_identity()
    
    date_str = request.args.get('date')
    
    query = DailyMealPlan.query.filter_by(user_id=user_id)
    
    if date_str:
        try:
            plan_date = datetime.strptime(date_str, '%Y-%m-%d').date()
            query = query.filter_by(date=plan_date)
        except ValueError:
            return jsonify({'error': 'Invalid date format. Use YYYY-MM-DD'}), 400
    
    plans = query.order_by(DailyMealPlan.date.desc()).all()
    
    return jsonify({
        'plans': [p.to_dict() for p in plans],
        'count': len(plans)
    }), 200


@meals_bp.route('/plans/<int:plan_id>', methods=['GET'])
@jwt_required()
def get_meal_plan(plan_id):
    """Get specific meal plan"""
    user_id = get_jwt_identity()
    plan = DailyMealPlan.query.filter_by(id=plan_id, user_id=user_id).first_or_404()
    
    return jsonify({'plan': plan.to_dict()}), 200


@meals_bp.route('/plans', methods=['POST'])
@jwt_required()
def create_meal_plan():
    """Create a daily meal plan"""
    user_id = get_jwt_identity()
    data = request.get_json()
    
    date_str = data.get('date')
    if not date_str:
        return jsonify({'error': 'Date is required'}), 400
    
    try:
        plan_date = datetime.strptime(date_str, '%Y-%m-%d').date()
    except ValueError:
        return jsonify({'error': 'Invalid date format. Use YYYY-MM-DD'}), 400
    
    existing = DailyMealPlan.query.filter_by(user_id=user_id, date=plan_date).first()
    if existing:
        return jsonify({'error': 'Meal plan already exists for this date'}), 409
    
    plan = DailyMealPlan(
        user_id=user_id,
        date=plan_date,
        breakfast_id=data.get('breakfast_id'),
        lunch_id=data.get('lunch_id'),
        dinner_id=data.get('dinner_id'),
        snack_id=data.get('snack_id')
    )
    
    db.session.add(plan)
    db.session.flush()
    
    plan.calculate_totals()
    db.session.commit()
    
    return jsonify({
        'message': 'Meal plan created successfully',
        'plan': plan.to_dict()
    }), 201


@meals_bp.route('/plans/<int:plan_id>', methods=['PUT'])
@jwt_required()
def update_meal_plan(plan_id):
    """Update a meal plan"""
    user_id = get_jwt_identity()
    plan = DailyMealPlan.query.filter_by(id=plan_id, user_id=user_id).first_or_404()
    
    data = request.get_json()
    
    if 'breakfast_id' in data:
        plan.breakfast_id = data['breakfast_id']
    if 'lunch_id' in data:
        plan.lunch_id = data['lunch_id']
    if 'dinner_id' in data:
        plan.dinner_id = data['dinner_id']
    if 'snack_id' in data:
        plan.snack_id = data['snack_id']
    
    db.session.flush()
    plan.calculate_totals()
    db.session.commit()
    
    return jsonify({
        'message': 'Meal plan updated successfully',
        'plan': plan.to_dict()
    }), 200


@meals_bp.route('/plans/<int:plan_id>', methods=['DELETE'])
@jwt_required()
def delete_meal_plan(plan_id):
    """Delete a meal plan"""
    user_id = get_jwt_identity()
    plan = DailyMealPlan.query.filter_by(id=plan_id, user_id=user_id).first_or_404()
    
    db.session.delete(plan)
    db.session.commit()
    
    return jsonify({'message': 'Meal plan deleted successfully'}), 200


# ========== STATISTICS ==========

@meals_bp.route('/stats/summary', methods=['GET'])
def get_meals_summary():
    """Get summary statistics of available meals"""
    
    stats = {
        'total_meals': Meal.query.count(),
        'by_type': {},
        'by_goal': {},
        'total_foods': Food.query.count()
    }
    
    for meal_type in ['breakfast', 'lunch', 'dinner', 'snack']:
        count = Meal.query.filter_by(meal_type=meal_type).count()
        stats['by_type'][meal_type] = count
    
    for goal in ['weight_loss', 'muscle_gain', 'maintenance']:
        count = Meal.query.filter_by(goal=goal).count()
        stats['by_goal'][goal] = count
    
    return jsonify({'stats': stats}), 200


@meals_bp.route('/plans/stats', methods=['GET'])
@jwt_required()
def get_user_meal_stats():
    """Get user's meal plan statistics"""
    user_id = get_jwt_identity()
    
    days = int(request.args.get('days', 30))
    
    plans = DailyMealPlan.query.filter_by(user_id=user_id)\
        .order_by(DailyMealPlan.date.desc())\
        .limit(days)\
        .all()
    
    if not plans:
        return jsonify({
            'stats': {
                'total_plans': 0,
                'average_calories': 0,
                'average_protein': 0,
                'average_carbs': 0,
                'average_fat': 0
            }
        }), 200
    
    total_calories = sum(p.total_calories for p in plans)
    total_protein = sum(p.total_protein for p in plans)
    total_carbs = sum(p.total_carbs for p in plans)
    total_fat = sum(p.total_fat for p in plans)
    
    count = len(plans)
    
    stats = {
        'total_plans': count,
        'average_calories': round(total_calories / count, 1),
        'average_protein': round(total_protein / count, 1),
        'average_carbs': round(total_carbs / count, 1),
        'average_fat': round(total_fat / count, 1),
        'date_range': {
            'from': plans[-1].date.isoformat(),
            'to': plans[0].date.isoformat()
        }
    }
    
    return jsonify({'stats': stats}), 200


# ========== AI MEAL PLAN GENERATION ==========

@meals_bp.route('/generate-plan', methods=['POST'])
@jwt_required()
def generate_meal_plan():
    """Trigger AI meal plan generation"""
    user_id = get_jwt_identity()
    user = User.query.get_or_404(user_id)
    data = request.get_json()
    
    # Validate required fields
    required = ['goal_weight', 'days_to_goal', 'goal']
    if not all(field in data for field in required):
        return jsonify({'error': 'Missing required fields: goal_weight, days_to_goal, goal'}), 400
    
    # Create pending schedule
    schedule = MealSchedule(
        user_id=user_id,
        current_weight=user.weight or data.get('current_weight'),
        goal_weight=data['goal_weight'],
        days_to_goal=data['days_to_goal'],
        goal=data['goal'],
        generation_status='pending'
    )
    db.session.add(schedule)
    db.session.commit()
    
    # Prepare payload for n8n
    payload = {
        'user_id': user_id,
        'schedule_id': schedule.id,
        'current_weight': user.weight or data.get('current_weight'),
        'goal_weight': data['goal_weight'],
        'days_to_goal': data['days_to_goal'],
        'goal': data['goal'],
        'age': user.age,
        'gender': user.gender,
        'height': user.height,
        'activity_level': data.get('activity_level', 'moderate'),
        'dietary_restrictions': data.get('dietary_restrictions', []),
        'meals_per_day': data.get('meals_per_day', 4)
    }
    
    # Call n8n webhook
    N8N_URL = os.getenv('N8N_MEAL_WEBHOOK_URL', 'http://localhost:5678/webhook/generate-meal-plan')
    
    try:
        response = requests.post(N8N_URL, json=payload, timeout=300)
        
        if response.status_code == 200:
            schedule.generation_status = 'processing'
            db.session.commit()
            
            return jsonify({
                'message': 'Meal plan generation started',
                'schedule_id': schedule.id,
                'status': 'processing'
            }), 202
        else:
            schedule.generation_status = 'failed'
            db.session.commit()
            return jsonify({'error': 'Failed to trigger n8n workflow'}), 500
            
    except Exception as e:
        schedule.generation_status = 'failed'
        db.session.commit()
        return jsonify({'error': str(e)}), 500

@meals_bp.route('/webhook/plan-ready', methods=['POST'])
def receive_meal_plan():
    """Webhook to receive AI-generated meal plan from n8n"""
    data = request.get_json()
    
    print("📥 Received meal plan webhook")
    
    if not data or not data.get('user_id') or not data.get('weekly_meal_plan'):
        print("❌ Invalid payload")
        return jsonify({'error': 'Invalid payload'}), 400
    
    try:
        user_id = data['user_id']
        schedule_id = data.get('schedule_id')
        
        # CASE 1: Update existing schedule (if schedule_id provided and exists)
        if schedule_id:
            schedule = MealSchedule.query.get(schedule_id)
            if not schedule:
                print(f"⚠️ Schedule {schedule_id} not found, creating new one")
                schedule = MealSchedule(user_id=user_id)
                db.session.add(schedule)
            else:
                print(f"♻️ Updating existing schedule {schedule_id}")
        # CASE 2: Create new schedule (if no schedule_id)
        else:
            print(f"🆕 Creating new schedule for user {user_id}")
            schedule = MealSchedule(user_id=user_id)
            db.session.add(schedule)
        
        # Update schedule data
        schedule.weekly_plan = data['weekly_meal_plan']
        schedule.generation_status = 'completed'
        schedule.generated_at = datetime.utcnow()
        schedule.is_active = True  # Optional: auto-activate
        
        # Store nutrition targets
        nutrition_targets = data.get('nutrition_targets', {})
        schedule.daily_calories = nutrition_targets.get('daily_calories')
        schedule.daily_protein = nutrition_targets.get('daily_protein')
        schedule.daily_carbs = nutrition_targets.get('daily_carbs')
        schedule.daily_fat = nutrition_targets.get('daily_fat')
        
        # Store user data snapshot
        user_data = data.get('user_data', {})
        schedule.current_weight = user_data.get('current_weight')
        schedule.goal_weight = user_data.get('goal_weight')
        schedule.days_to_goal = user_data.get('days_to_goal')
        schedule.goal = user_data.get('goal')
        
        db.session.commit()
        
        print(f"✅ Meal plan saved successfully - Schedule ID: {schedule.id}")
        
        return jsonify({
            'message': 'Meal plan saved successfully',
            'schedule_id': schedule.id,
            'user_id': user_id,
            'action': 'updated' if schedule_id else 'created'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'error': 'Failed to save meal plan',
            'details': str(e)
        }), 500

# ========== MEAL SCHEDULES ==========

@meals_bp.route('/schedules', methods=['GET'])
@jwt_required()
def get_meal_schedules():
    """Get user's meal schedules"""
    user_id = get_jwt_identity()
    
    active_only = request.args.get('active', 'false').lower() == 'true'
    
    query = MealSchedule.query.filter_by(user_id=user_id)
    
    if active_only:
        query = query.filter_by(is_active=True)
    
    schedules = query.order_by(MealSchedule.generated_at.desc()).all()
    
    return jsonify({
        'schedules': [s.to_dict() for s in schedules],
        'count': len(schedules)
    }), 200


@meals_bp.route('/schedules/<int:schedule_id>', methods=['GET'])
@jwt_required()
def get_meal_schedule(schedule_id):
    """Get specific meal schedule with full weekly plan"""
    user_id = get_jwt_identity()
    schedule = MealSchedule.query.filter_by(id=schedule_id, user_id=user_id).first_or_404()
    
    return jsonify({'schedule': schedule.to_dict()}), 200


@meals_bp.route('/schedules/<int:schedule_id>/activate', methods=['POST'])
@jwt_required()
def activate_meal_schedule(schedule_id):
    """Set a meal schedule as active (deactivate others)"""
    user_id = get_jwt_identity()
    
    # Deactivate all user's schedules
    MealSchedule.query.filter_by(user_id=user_id).update({'is_active': False})
    
    # Activate the selected one
    schedule = MealSchedule.query.filter_by(id=schedule_id, user_id=user_id).first_or_404()
    schedule.is_active = True
    
    db.session.commit()
    
    return jsonify({
        'message': 'Meal schedule activated',
        'schedule': schedule.to_dict()
    }), 200
@meals_bp.route('/schedules/active', methods=['GET'])
@jwt_required()
def get_active_schedule():
    """Get user's currently active meal schedule"""
    user_id = get_jwt_identity()
    
    schedule = MealSchedule.query.filter_by(
        user_id=user_id, 
        is_active=True
    ).first()
    
    if not schedule:
        return jsonify({
            'message': 'No active meal schedule',
            'schedule': None
        }), 200
    
    return jsonify({
        'schedule': schedule.to_dict()
    }), 200
@meals_bp.route('/schedules/<int:schedule_id>/day/<string:day>', methods=['GET'])
@jwt_required()
def get_schedule_day(schedule_id, day):
    """Get a specific day's meals from a schedule"""
    user_id = get_jwt_identity()
    
    # Validate day
    valid_days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    if day.lower() not in valid_days:
        return jsonify({'error': 'Invalid day. Use: monday-sunday'}), 400
    
    schedule = MealSchedule.query.filter_by(
        id=schedule_id, 
        user_id=user_id
    ).first_or_404()
    
    if not schedule.weekly_plan:
        return jsonify({'error': 'Schedule has no meal plan'}), 404
    
    day_plan = schedule.weekly_plan.get(day.lower())
    
    if not day_plan:
        return jsonify({'error': f'No meals found for {day}'}), 404
    
    return jsonify({
        'day': day.lower(),
        'schedule_id': schedule_id,
        'meals': day_plan
    }), 200
@meals_bp.route('/schedules/<int:schedule_id>', methods=['DELETE'])
@jwt_required()
def delete_schedule(schedule_id):
    """Delete a meal schedule"""
    user_id = get_jwt_identity()
    
    schedule = MealSchedule.query.filter_by(
        id=schedule_id,
        user_id=user_id
    ).first_or_404()
    
    db.session.delete(schedule)
    db.session.commit()
    
    return jsonify({
        'message': 'Meal schedule deleted successfully',
        'schedule_id': schedule_id
    }), 200
@meals_bp.route('/schedules/<int:schedule_id>/summary', methods=['GET'])
@jwt_required()
def get_schedule_summary(schedule_id):
    """Get nutrition summary for entire week"""
    user_id = get_jwt_identity()
    
    schedule = MealSchedule.query.filter_by(
        id=schedule_id,
        user_id=user_id
    ).first_or_404()
    
    if not schedule.weekly_plan:
        return jsonify({'error': 'Schedule has no meal plan'}), 404
    
    # Calculate weekly totals
    weekly_totals = {
        'calories': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0
    }
    
    days_with_data = 0
    
    for day in ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']:
        day_plan = schedule.weekly_plan.get(day)
        if day_plan and day_plan.get('daily_totals'):
            totals = day_plan['daily_totals']
            weekly_totals['calories'] += totals.get('calories', 0)
            weekly_totals['protein'] += totals.get('protein', 0)
            weekly_totals['carbs'] += totals.get('carbs', 0)
            weekly_totals['fat'] += totals.get('fat', 0)
            days_with_data += 1
    
    # Calculate averages
    weekly_averages = {
        'calories': round(weekly_totals['calories'] / days_with_data, 1) if days_with_data > 0 else 0,
        'protein': round(weekly_totals['protein'] / days_with_data, 1) if days_with_data > 0 else 0,
        'carbs': round(weekly_totals['carbs'] / days_with_data, 1) if days_with_data > 0 else 0,
        'fat': round(weekly_totals['fat'] / days_with_data, 1) if days_with_data > 0 else 0
    }
    
    return jsonify({
        'schedule_id': schedule_id,
        'weekly_totals': weekly_totals,
        'daily_averages': weekly_averages,
        'targets': {
            'calories': schedule.daily_calories,
            'protein': schedule.daily_protein,
            'carbs': schedule.daily_carbs,
            'fat': schedule.daily_fat
        },
        'days_count': days_with_data
    }), 200
