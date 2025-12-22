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