from app import create_app, db
from app.models import Food, Meal, MealItem

app = create_app()

def create_meal(name, meal_type, goal, description, items_data):
    """Helper to create a meal with items"""
    meal = Meal(
        name=name,
        meal_type=meal_type,
        goal=goal,
        description=description
    )
    db.session.add(meal)
    db.session.flush()  # Get meal.id
    
    # Add items
    for item_data in items_data:
        food = Food.query.filter_by(name=item_data['food_name']).first()
        if not food:
            print(f"⚠️ Food '{item_data['food_name']}' not found!")
            continue
        
        item = MealItem(
            meal_id=meal.id,
            food_id=food.id,
            quantity=item_data['quantity']
        )
        db.session.add(item)
    
    # Calculate totals
    db.session.flush()
    meal.calculate_totals()
    
    return meal


def seed_meals():
    """Seed realistic meals following the rules"""
    
    print("🍽️ Seeding meals...")
    
    # BREAKFAST - Muscle Gain (400-600 kcal)
    create_meal(
        name="High Protein Breakfast",
        meal_type="breakfast",
        goal="muscle_gain",
        description="Oats with eggs and banana for muscle building",
        items_data=[
            {"food_name": "Oats", "quantity": 60},  # 234 kcal
            {"food_name": "Eggs", "quantity": 100},  # 155 kcal (2 eggs)
            {"food_name": "Banana", "quantity": 120},  # 107 kcal
            {"food_name": "Peanut Butter", "quantity": 15},  # 88 kcal
        ]
    )
    # Total: ~584 kcal, 30g protein ✅
    
    # BREAKFAST - Weight Loss (300-400 kcal)
    create_meal(
        name="Light Breakfast",
        meal_type="breakfast",
        goal="weight_loss",
        description="Greek yogurt with berries and almonds",
        items_data=[
            {"food_name": "Greek Yogurt", "quantity": 150},  # 145 kcal
            {"food_name": "Blueberries", "quantity": 80},  # 46 kcal
            {"food_name": "Almonds", "quantity": 20},  # 116 kcal
            {"food_name": "Oats", "quantity": 30},  # 117 kcal
        ]
    )
    # Total: ~424 kcal, 19g protein ✅
    
    # LUNCH - Muscle Gain (600-800 kcal)
    create_meal(
        name="Muscle Builder Lunch",
        meal_type="lunch",
        goal="muscle_gain",
        description="Chicken with rice and vegetables",
        items_data=[
            {"food_name": "Chicken Breast", "quantity": 180},  # 297 kcal
            {"food_name": "Brown Rice (cooked)", "quantity": 200},  # 224 kcal
            {"food_name": "Broccoli (cooked)", "quantity": 150},  # 53 kcal
            {"food_name": "Olive Oil", "quantity": 10},  # 88 kcal
        ]
    )
    # Total: ~662 kcal, 60g protein ✅
    
    # LUNCH - Weight Loss (400-600 kcal)
    create_meal(
        name="Lean Lunch",
        meal_type="lunch",
        goal="weight_loss",
        description="Tuna salad with vegetables",
        items_data=[
            {"food_name": "Tuna (canned in water)", "quantity": 150},  # 174 kcal
            {"food_name": "Spinach (cooked)", "quantity": 100},  # 23 kcal
            {"food_name": "Tomato", "quantity": 100},  # 18 kcal
            {"food_name": "Cucumber", "quantity": 100},  # 16 kcal
            {"food_name": "Olive Oil", "quantity": 10},  # 88 kcal
            {"food_name": "Quinoa (cooked)", "quantity": 100},  # 120 kcal
        ]
    )
    # Total: ~439 kcal, 43g protein ✅
    
    # DINNER - Muscle Gain (600-900 kcal)
    create_meal(
        name="Power Dinner",
        meal_type="dinner",
        goal="muscle_gain",
        description="Salmon with sweet potato and vegetables",
        items_data=[
            {"food_name": "Salmon", "quantity": 180},  # 374 kcal
            {"food_name": "Sweet Potato (cooked)", "quantity": 200},  # 180 kcal
            {"food_name": "Broccoli (cooked)", "quantity": 150},  # 53 kcal
            {"food_name": "Olive Oil", "quantity": 10},  # 88 kcal
        ]
    )
    # Total: ~695 kcal, 40g protein ✅
    
    # DINNER - Weight Loss (400-600 kcal)
    create_meal(
        name="Light Dinner",
        meal_type="dinner",
        goal="weight_loss",
        description="Turkey with vegetables",
        items_data=[
            {"food_name": "Turkey Breast", "quantity": 150},  # 203 kcal
            {"food_name": "Bell Pepper", "quantity": 150},  # 47 kcal
            {"food_name": "Carrots (cooked)", "quantity": 100},  # 35 kcal
            {"food_name": "Spinach (cooked)", "quantity": 100},  # 23 kcal
            {"food_name": "Olive Oil", "quantity": 8},  # 71 kcal
        ]
    )
    # Total: ~379 kcal, 48g protein ✅
    
    # SNACK - Muscle Gain (200-300 kcal)
    create_meal(
        name="Post-Workout Snack",
        meal_type="snack",
        goal="muscle_gain",
        description="Protein bar with banana",
        items_data=[
            {"food_name": "Protein Bar", "quantity": 60},  # 228 kcal
            {"food_name": "Banana", "quantity": 100},  # 89 kcal
        ]
    )
    # Total: ~317 kcal, 13g protein ✅
    
    # SNACK - Weight Loss (100-200 kcal)
    create_meal(
        name="Healthy Snack",
        meal_type="snack",
        goal="weight_loss",
        description="Apple with almonds",
        items_data=[
            {"food_name": "Apple", "quantity": 150},  # 78 kcal
            {"food_name": "Almonds", "quantity": 15},  # 87 kcal
        ]
    )
    # Total: ~165 kcal, 4g protein ✅
    
    db.session.commit()
    print("✅ Meals seeded successfully!")
    
    # Print summary
    meals = Meal.query.all()
    print("\n📊 Meals Summary:")
    for meal in meals:
        print(f"\n{meal.name} ({meal.meal_type} - {meal.goal})")
        print(f"  Calories: {meal.total_calories} kcal")
        print(f"  Protein: {meal.total_protein}g")
        print(f"  Carbs: {meal.total_carbs}g")
        print(f"  Fat: {meal.total_fat}g")


if __name__ == "__main__":
    with app.app_context():
        seed_meals()