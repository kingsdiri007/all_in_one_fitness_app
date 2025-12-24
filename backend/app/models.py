from app import db
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    first_name = db.Column(db.String(50))
    last_name = db.Column(db.String(50))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Biometric data
    age = db.Column(db.Integer)
    weight = db.Column(db.Float)  # in kg
    height = db.Column(db.Float)  # in cm
    gender = db.Column(db.String(10))
    fitness_goal = db.Column(db.String(50))  # weight_loss, muscle_gain, fitness
    
    # Relationships
    workouts = db.relationship('UserWorkout', backref='user', lazy=True, cascade='all, delete-orphan')
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        return {
            'id': self.id,
            'email': self.email,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'age': self.age,
            'weight': self.weight,
            'height': self.height,
            'gender': self.gender,
            'fitness_goal': self.fitness_goal,
            'created_at': self.created_at.isoformat()
        }
    def get_workout_stats(self):
        """Get user's workout statistics"""
        total_sessions = WorkoutSession.query.filter_by(user_id=self.id).count()
        completed_sessions = WorkoutSession.query.filter_by(
            user_id=self.id, 
            completed=True
        ).count()
        
        # Last workout date
        last_workout = WorkoutSession.query.filter_by(
            user_id=self.id,
            completed=True
        ).order_by(WorkoutSession.completed_at.desc()).first()
        
        return {
            'total_sessions': total_sessions,
            'completed_sessions': completed_sessions,
            'completion_rate': round((completed_sessions / total_sessions * 100), 1) if total_sessions > 0 else 0,
            'last_workout': last_workout.completed_at.isoformat() if last_workout else None
        }


class Exercise(db.Model):
    """Pool of all available exercises"""
    __tablename__ = "exercises"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    muscle_group = db.Column(db.String(50), nullable=False)  # chest, back, legs, shoulders, arms, core
    equipment = db.Column(db.String(50))  # barbell, dumbbell, bodyweight, machine
    difficulty = db.Column(db.String(20))  # beginner, intermediate, advanced
    instructions = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'muscle_group': self.muscle_group,
            'equipment': self.equipment,
            'difficulty': self.difficulty,
            'instructions': self.instructions
        }


class WorkoutTemplate(db.Model):
    """Pre-made workout templates (Push Day, Pull Day, Leg Day, etc.)"""
    __tablename__ = "workout_templates"
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    goal = db.Column(db.String(50))  # muscle_gain, weight_loss, strength, endurance
    level = db.Column(db.String(20))  # beginner, intermediate, advanced
    duration_minutes = db.Column(db.Integer)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationship with exercises
    exercises = db.relationship('WorkoutExercise', backref='workout_template', lazy=True, cascade='all, delete-orphan')

    def to_dict(self, include_exercises=False):
        result = {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'goal': self.goal,
            'level': self.level,
            'duration_minutes': self.duration_minutes
        }
        
        if include_exercises:
            result['exercises'] = [we.to_dict() for we in self.exercises]
        
        return result


class WorkoutExercise(db.Model):
    """Join table between WorkoutTemplate and Exercise with workout-specific details"""
    __tablename__ = "workout_exercises"
    
    id = db.Column(db.Integer, primary_key=True)
    workout_id = db.Column(db.Integer, db.ForeignKey('workout_templates.id'), nullable=False)
    exercise_id = db.Column(db.Integer, db.ForeignKey('exercises.id'), nullable=False)
    
    sets = db.Column(db.Integer, nullable=False)
    reps = db.Column(db.Integer, nullable=False)
    rest_seconds = db.Column(db.Integer, default=60)
    order = db.Column(db.Integer)  # Order of exercise in workout
    
    # Relationship to Exercise
    exercise = db.relationship('Exercise', backref='workout_exercises')

    def to_dict(self):
        return {
            'id': self.id,
            'exercise': self.exercise.to_dict(),
            'sets': self.sets,
            'reps': self.reps,
            'rest_seconds': self.rest_seconds,
            'order': self.order
        }


class UserWorkout(db.Model):
    """User's assigned/saved workouts"""
    __tablename__ = "user_workouts"
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    template_id = db.Column(db.Integer, db.ForeignKey('workout_templates.id'), nullable=False)
    assigned_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)
    
    # Relationship
    template = db.relationship('WorkoutTemplate')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'template': self.template.to_dict(include_exercises=True),
            'assigned_at': self.assigned_at.isoformat(),
            'is_active': self.is_active
        }
class WorkoutSession(db.Model):
    """A specific workout session for a user"""
    __tablename__ = "workout_sessions"
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    template_id = db.Column(db.Integer, db.ForeignKey('workout_templates.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    completed = db.Column(db.Boolean, default=False)
    completed_at = db.Column(db.DateTime, nullable=True)
    
    # Relationships
    user = db.relationship('User', backref='workout_sessions')
    template = db.relationship('WorkoutTemplate')
    exercises = db.relationship('SessionExercise', backref='session', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'template': self.template.to_dict(),
            'created_at': self.created_at.isoformat(),
            'completed': self.completed,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None,
            'exercises': [e.to_dict() for e in self.exercises]
        }


class SessionExercise(db.Model):
    """Exercise within a specific workout session"""
    __tablename__ = "session_exercises"
    
    id = db.Column(db.Integer, primary_key=True)
    session_id = db.Column(db.Integer, db.ForeignKey('workout_sessions.id'), nullable=False)
    exercise_id = db.Column(db.Integer, db.ForeignKey('exercises.id'), nullable=False)
    sets = db.Column(db.Integer)
    reps = db.Column(db.Integer)
    rest_seconds = db.Column(db.Integer)
    order = db.Column(db.Integer)
    completed = db.Column(db.Boolean, default=False)
    
    # Performance tracking (optional)
    weight_used = db.Column(db.Float, nullable=True)  # kg
    actual_reps = db.Column(db.Integer, nullable=True)  # What user actually did
    
    exercise = db.relationship('Exercise')
    
    def to_dict(self):
        return {
            'id': self.id,
            'exercise': self.exercise.to_dict(),
            'sets': self.sets,
            'reps': self.reps,
            'rest_seconds': self.rest_seconds,
            'order': self.order,
            'completed': self.completed,
            'weight_used': self.weight_used,
            'actual_reps': self.actual_reps
        }
class WeightHistory(db.Model):
    """Track user's weight over time"""
    __tablename__ = "weight_history"
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    weight = db.Column(db.Float, nullable=False)  # kg
    recorded_at = db.Column(db.DateTime, default=datetime.utcnow)
    notes = db.Column(db.String(255))
    
    user = db.relationship('User', backref='weight_history')
    
    def to_dict(self):
        return {
            'id': self.id,
            'weight': self.weight,
            'recorded_at': self.recorded_at.isoformat(),
            'notes': self.notes
        }


class ExercisePersonalRecord(db.Model):
    """Track user's personal records (PRs) for exercises"""
    __tablename__ = "exercise_personal_records"
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    exercise_id = db.Column(db.Integer, db.ForeignKey('exercises.id'), nullable=False)
    weight = db.Column(db.Float, nullable=False)  # kg
    reps = db.Column(db.Integer, nullable=False)
    achieved_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    user = db.relationship('User', backref='personal_records')
    exercise = db.relationship('Exercise')
    
    def to_dict(self):
        return {
            'id': self.id,
            'exercise': self.exercise.to_dict(),
            'weight': self.weight,
            'reps': self.reps,
            'achieved_at': self.achieved_at.isoformat()
        }
class UserSchedule(db.Model):
    """User's weekly workout schedule generated by AI"""
    __tablename__ = "user_schedules"
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    
    # User preferences for AI generation
    available_days = db.Column(db.JSON)  # ["monday", "wednesday", "friday"]
    available_time_slots = db.Column(db.JSON)  # {"monday": "morning", "wednesday": "evening"}
    sessions_per_week = db.Column(db.Integer, default=3)
    session_duration = db.Column(db.Integer, default=60)  # minutes
    
    # AI-generated plan
    weekly_plan = db.Column(db.JSON)  # Complete weekly schedule
    generated_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)
    
    # n8n workflow tracking
    n8n_workflow_id = db.Column(db.String(100))
    generation_status = db.Column(db.String(20), default='pending')  # pending, processing, completed, failed
    
    user = db.relationship('User', backref='schedules')
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'available_days': self.available_days,
            'available_time_slots': self.available_time_slots,
            'sessions_per_week': self.sessions_per_week,
            'session_duration': self.session_duration,
            'weekly_plan': self.weekly_plan,
            'generated_at': self.generated_at.isoformat(),
            'is_active': self.is_active,
            'generation_status': self.generation_status
        }


class CalendarEvent(db.Model):
    """Workout events in user's calendar"""
    __tablename__ = "calendar_events"
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    schedule_id = db.Column(db.Integer, db.ForeignKey('user_schedules.id'))
    
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    
    # Date and time
    date = db.Column(db.Date, nullable=False)
    start_time = db.Column(db.Time)
    end_time = db.Column(db.Time)
    duration_minutes = db.Column(db.Integer)
    
    # Workout details
    workout_template_id = db.Column(db.Integer, db.ForeignKey('workout_templates.id'))
    exercises = db.Column(db.JSON)  # List of exercises for this session
    
    # Status
    completed = db.Column(db.Boolean, default=False)
    completed_at = db.Column(db.DateTime)
    reminder_sent = db.Column(db.Boolean, default=False)
    
    user = db.relationship('User', backref='calendar_events')
    schedule = db.relationship('UserSchedule')
    template = db.relationship('WorkoutTemplate')
    
    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'date': self.date.isoformat(),
            'start_time': self.start_time.isoformat() if self.start_time else None,
            'end_time': self.end_time.isoformat() if self.end_time else None,
            'duration_minutes': self.duration_minutes,
            'workout_template': self.template.to_dict() if self.template else None,
            'exercises': self.exercises,
            'completed': self.completed,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None
        }
class Food(db.Model):
    """Atomic unit - source of truth for nutrition"""
    __tablename__ = "foods"
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    category = db.Column(db.String(50), nullable=False)  # protein, carb, fat, vegetable, fruit, snack
    
    # Nutrition per 100g (industry standard)
    calories_per_100g = db.Column(db.Float, nullable=False)
    protein_per_100g = db.Column(db.Float, nullable=False)
    carbs_per_100g = db.Column(db.Float, nullable=False)
    fat_per_100g = db.Column(db.Float, nullable=False)
    
    # Meta
    unit = db.Column(db.String(10), default='g')  # g, ml, piece
    is_common = db.Column(db.Boolean, default=False)  # For suggestions
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def calculate_nutrition(self, quantity_grams):
        """Calculate nutrition for a given quantity"""
        multiplier = quantity_grams / 100
        return {
            'calories': round(self.calories_per_100g * multiplier, 1),
            'protein': round(self.protein_per_100g * multiplier, 1),
            'carbs': round(self.carbs_per_100g * multiplier, 1),
            'fat': round(self.fat_per_100g * multiplier, 1)
        }
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'category': self.category,
            'calories_per_100g': self.calories_per_100g,
            'protein_per_100g': self.protein_per_100g,
            'carbs_per_100g': self.carbs_per_100g,
            'fat_per_100g': self.fat_per_100g,
            'unit': self.unit,
            'is_common': self.is_common
        }


class Meal(db.Model):
    """Logical combination of foods with intent"""
    __tablename__ = "meals"
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    meal_type = db.Column(db.String(20), nullable=False)  # breakfast, lunch, dinner, snack
    goal = db.Column(db.String(50))  # weight_loss, muscle_gain, maintenance
    description = db.Column(db.Text)
    
    # Cached totals (calculated from items)
    total_calories = db.Column(db.Float, default=0)
    total_protein = db.Column(db.Float, default=0)
    total_carbs = db.Column(db.Float, default=0)
    total_fat = db.Column(db.Float, default=0)
    
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    items = db.relationship('MealItem', backref='meal', lazy=True, cascade='all, delete-orphan')
    
    def calculate_totals(self):
        """Calculate and cache nutrition totals from all items"""
        self.total_calories = 0
        self.total_protein = 0
        self.total_carbs = 0
        self.total_fat = 0
        
        for item in self.items:
            nutrition = item.food.calculate_nutrition(item.quantity)
            self.total_calories += nutrition['calories']
            self.total_protein += nutrition['protein']
            self.total_carbs += nutrition['carbs']
            self.total_fat += nutrition['fat']
        
        # Round totals
        self.total_calories = round(self.total_calories, 1)
        self.total_protein = round(self.total_protein, 1)
        self.total_carbs = round(self.total_carbs, 1)
        self.total_fat = round(self.total_fat, 1)
    
    def to_dict(self, include_items=False):
        result = {
            'id': self.id,
            'name': self.name,
            'meal_type': self.meal_type,
            'goal': self.goal,
            'description': self.description,
            'total_calories': self.total_calories,
            'total_protein': self.total_protein,
            'total_carbs': self.total_carbs,
            'total_fat': self.total_fat,
            'created_at': self.created_at.isoformat()
        }
        
        if include_items:
            result['items'] = [item.to_dict() for item in self.items]
        
        return result


class MealItem(db.Model):
    """The glue - prevents chaos"""
    __tablename__ = "meal_items"
    
    id = db.Column(db.Integer, primary_key=True)
    meal_id = db.Column(db.Integer, db.ForeignKey('meals.id'), nullable=False)
    food_id = db.Column(db.Integer, db.ForeignKey('foods.id'), nullable=False)
    quantity = db.Column(db.Float, nullable=False)  # in grams or ml
    
    # Relationships
    food = db.relationship('Food', backref='meal_items')
    
    def to_dict(self):
        nutrition = self.food.calculate_nutrition(self.quantity)
        return {
            'id': self.id,
            'food': self.food.to_dict(),
            'quantity': self.quantity,
            'nutrition': nutrition
        }


class DailyMealPlan(db.Model):
    """User's daily meal plan (for n8n integration later)"""
    __tablename__ = "daily_meal_plans"
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    date = db.Column(db.Date, nullable=False)
    
    breakfast_id = db.Column(db.Integer, db.ForeignKey('meals.id'))
    lunch_id = db.Column(db.Integer, db.ForeignKey('meals.id'))
    dinner_id = db.Column(db.Integer, db.ForeignKey('meals.id'))
    snack_id = db.Column(db.Integer, db.ForeignKey('meals.id'))
    
    # Totals for the day
    total_calories = db.Column(db.Float, default=0)
    total_protein = db.Column(db.Float, default=0)
    total_carbs = db.Column(db.Float, default=0)
    total_fat = db.Column(db.Float, default=0)
    
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', backref='meal_plans')
    breakfast = db.relationship('Meal', foreign_keys=[breakfast_id])
    lunch = db.relationship('Meal', foreign_keys=[lunch_id])
    dinner = db.relationship('Meal', foreign_keys=[dinner_id])
    snack = db.relationship('Meal', foreign_keys=[snack_id])
    
    def calculate_totals(self):
        """Calculate daily totals"""
        self.total_calories = 0
        self.total_protein = 0
        self.total_carbs = 0
        self.total_fat = 0
        
        for meal in [self.breakfast, self.lunch, self.dinner, self.snack]:
            if meal:
                self.total_calories += meal.total_calories
                self.total_protein += meal.total_protein
                self.total_carbs += meal.total_carbs
                self.total_fat += meal.total_fat
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'date': self.date.isoformat(),
            'breakfast': self.breakfast.to_dict(include_items=True) if self.breakfast else None,
            'lunch': self.lunch.to_dict(include_items=True) if self.lunch else None,
            'dinner': self.dinner.to_dict(include_items=True) if self.dinner else None,
            'snack': self.snack.to_dict(include_items=True) if self.snack else None,
            'total_calories': self.total_calories,
            'total_protein': self.total_protein,
            'total_carbs': self.total_carbs,
            'total_fat': self.total_fat
        }
class MealSchedule(db.Model):
    """User's weekly meal schedule (similar to UserSchedule for workouts)"""
    __tablename__ = "meal_schedules"
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    
    # User nutrition targets
    daily_calories = db.Column(db.Integer)
    daily_protein = db.Column(db.Integer)
    daily_carbs = db.Column(db.Integer)
    daily_fat = db.Column(db.Integer)
    
    # User data snapshot
    current_weight = db.Column(db.Float)
    goal_weight = db.Column(db.Float)
    days_to_goal = db.Column(db.Integer)
    goal = db.Column(db.String(50))  # lose_fat, muscle_gain, maintenance
    
    # AI-generated plan (stores the full weekly JSON)
    weekly_plan = db.Column(db.JSON)
    
    # Metadata
    generated_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)
    generation_status = db.Column(db.String(20), default='pending')
    
    user = db.relationship('User', backref='meal_schedules')
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'daily_calories': self.daily_calories,
            'daily_protein': self.daily_protein,
            'daily_carbs': self.daily_carbs,
            'daily_fat': self.daily_fat,
            'current_weight': self.current_weight,
            'goal_weight': self.goal_weight,
            'days_to_goal': self.days_to_goal,
            'goal': self.goal,
            'weekly_plan': self.weekly_plan,
            'generated_at': self.generated_at.isoformat(),
            'is_active': self.is_active,
            'generation_status': self.generation_status
        }
