from app import create_app, db
from app.models import Exercise, WorkoutTemplate, WorkoutExercise

app = create_app()

def seed_exercises():
    """Seed basic exercises"""
    exercises_data = [
        # Chest
        {"name": "Bench Press", "muscle_group": "chest", "equipment": "barbell", "difficulty": "intermediate", "instructions": "Lower the bar to chest, press upward."},
        {"name": "Incline Dumbbell Press", "muscle_group": "chest", "equipment": "dumbbell", "difficulty": "intermediate", "instructions": "Press dumbbells at incline angle."},
        {"name": "Push-ups", "muscle_group": "chest", "equipment": "bodyweight", "difficulty": "beginner", "instructions": "Lower body until chest nearly touches floor."},
        
        # Back
        {"name": "Pull Up", "muscle_group": "back", "equipment": "bodyweight", "difficulty": "advanced", "instructions": "Pull body upward until chin passes bar."},
        {"name": "Barbell Row", "muscle_group": "back", "equipment": "barbell", "difficulty": "intermediate", "instructions": "Pull barbell to lower chest."},
        {"name": "Lat Pulldown", "muscle_group": "back", "equipment": "machine", "difficulty": "beginner", "instructions": "Pull bar down to upper chest."},
        
        # Legs
        {"name": "Squat", "muscle_group": "legs", "equipment": "barbell", "difficulty": "intermediate", "instructions": "Squat down until thighs parallel."},
        {"name": "Leg Press", "muscle_group": "legs", "equipment": "machine", "difficulty": "beginner", "instructions": "Press platform away with feet."},
        {"name": "Lunges", "muscle_group": "legs", "equipment": "bodyweight", "difficulty": "beginner", "instructions": "Step forward and lower hips."},
        
        # Shoulders
        {"name": "Shoulder Press", "muscle_group": "shoulders", "equipment": "dumbbell", "difficulty": "beginner", "instructions": "Press dumbbells overhead."},
        {"name": "Lateral Raise", "muscle_group": "shoulders", "equipment": "dumbbell", "difficulty": "beginner", "instructions": "Raise arms to sides."},
        
        # Arms
        {"name": "Bicep Curl", "muscle_group": "arms", "equipment": "dumbbell", "difficulty": "beginner", "instructions": "Curl dumbbells toward shoulders."},
        {"name": "Tricep Extension", "muscle_group": "arms", "equipment": "dumbbell", "difficulty": "beginner", "instructions": "Extend arms overhead."},
        
        # Core
        {"name": "Plank", "muscle_group": "core", "equipment": "bodyweight", "difficulty": "beginner", "instructions": "Hold body straight, core tight."},
        {"name": "Crunches", "muscle_group": "core", "equipment": "bodyweight", "difficulty": "beginner", "instructions": "Lift shoulders off ground."},
    ]

    for data in exercises_data:
        exists = Exercise.query.filter_by(name=data["name"]).first()
        if not exists:
            db.session.add(Exercise(**data))

    db.session.commit()
    print("✅ Exercises seeded")


def seed_workout_templates():
    """Seed workout templates"""
    
    # Push Day
    push_day = WorkoutTemplate.query.filter_by(name="Push Day").first()
    if not push_day:
        push_day = WorkoutTemplate(
            name="Push Day",
            description="Chest, shoulders and triceps workout",
            goal="muscle_gain",
            level="intermediate",
            duration_minutes=60
        )
        db.session.add(push_day)
        db.session.commit()

        # Add exercises to Push Day
        bench = Exercise.query.filter_by(name="Bench Press").first()
        incline = Exercise.query.filter_by(name="Incline Dumbbell Press").first()
        shoulder = Exercise.query.filter_by(name="Shoulder Press").first()
        tricep = Exercise.query.filter_by(name="Tricep Extension").first()

        db.session.add_all([
            WorkoutExercise(workout_id=push_day.id, exercise_id=bench.id, sets=4, reps=8, rest_seconds=90, order=1),
            WorkoutExercise(workout_id=push_day.id, exercise_id=incline.id, sets=3, reps=10, rest_seconds=60, order=2),
            WorkoutExercise(workout_id=push_day.id, exercise_id=shoulder.id, sets=3, reps=10, rest_seconds=60, order=3),
            WorkoutExercise(workout_id=push_day.id, exercise_id=tricep.id, sets=3, reps=12, rest_seconds=45, order=4),
        ])
        db.session.commit()
        print("✅ Push Day seeded")
    
    # Pull Day
    pull_day = WorkoutTemplate.query.filter_by(name="Pull Day").first()
    if not pull_day:
        pull_day = WorkoutTemplate(
            name="Pull Day",
            description="Back and biceps workout",
            goal="muscle_gain",
            level="intermediate",
            duration_minutes=55
        )
        db.session.add(pull_day)
        db.session.commit()

        pullup = Exercise.query.filter_by(name="Pull Up").first()
        row = Exercise.query.filter_by(name="Barbell Row").first()
        lat = Exercise.query.filter_by(name="Lat Pulldown").first()
        curl = Exercise.query.filter_by(name="Bicep Curl").first()

        db.session.add_all([
            WorkoutExercise(workout_id=pull_day.id, exercise_id=pullup.id, sets=3, reps=8, rest_seconds=90, order=1),
            WorkoutExercise(workout_id=pull_day.id, exercise_id=row.id, sets=4, reps=8, rest_seconds=90, order=2),
            WorkoutExercise(workout_id=pull_day.id, exercise_id=lat.id, sets=3, reps=12, rest_seconds=60, order=3),
            WorkoutExercise(workout_id=pull_day.id, exercise_id=curl.id, sets=3, reps=12, rest_seconds=45, order=4),
        ])
        db.session.commit()
        print("✅ Pull Day seeded")
    
    # Leg Day
    leg_day = WorkoutTemplate.query.filter_by(name="Leg Day").first()
    if not leg_day:
        leg_day = WorkoutTemplate(
            name="Leg Day",
            description="Complete leg workout",
            goal="muscle_gain",
            level="intermediate",
            duration_minutes=65
        )
        db.session.add(leg_day)
        db.session.commit()

        squat = Exercise.query.filter_by(name="Squat").first()
        leg_press = Exercise.query.filter_by(name="Leg Press").first()
        lunges = Exercise.query.filter_by(name="Lunges").first()

        db.session.add_all([
            WorkoutExercise(workout_id=leg_day.id, exercise_id=squat.id, sets=5, reps=5, rest_seconds=120, order=1),
            WorkoutExercise(workout_id=leg_day.id, exercise_id=leg_press.id, sets=4, reps=10, rest_seconds=90, order=2),
            WorkoutExercise(workout_id=leg_day.id, exercise_id=lunges.id, sets=3, reps=12, rest_seconds=60, order=3),
        ])
        db.session.commit()
        print("✅ Leg Day seeded")


if __name__ == "__main__":
    with app.app_context():
        print("🌱 Starting seed...")
        seed_exercises()
        seed_workout_templates()
        print("🎉 Seed complete!")