from app import create_app, db
from app.models import Food

app = create_app()

def seed_foods():
    """Seed realistic food database"""
    
    foods_data = [
        # PROTEINS
        {"name": "Chicken Breast", "category": "protein", "calories_per_100g": 165, "protein_per_100g": 31, "carbs_per_100g": 0, "fat_per_100g": 3.6, "unit": "g", "is_common": True},
        {"name": "Eggs", "category": "protein", "calories_per_100g": 155, "protein_per_100g": 13, "carbs_per_100g": 1.1, "fat_per_100g": 11, "unit": "g", "is_common": True},
        {"name": "Tuna (canned in water)", "category": "protein", "calories_per_100g": 116, "protein_per_100g": 26, "carbs_per_100g": 0, "fat_per_100g": 0.8, "unit": "g", "is_common": True},
        {"name": "Greek Yogurt", "category": "protein", "calories_per_100g": 97, "protein_per_100g": 10, "carbs_per_100g": 3.6, "fat_per_100g": 5, "unit": "g", "is_common": True},
        {"name": "Salmon", "category": "protein", "calories_per_100g": 208, "protein_per_100g": 20, "carbs_per_100g": 0, "fat_per_100g": 13, "unit": "g", "is_common": True},
        {"name": "Turkey Breast", "category": "protein", "calories_per_100g": 135, "protein_per_100g": 30, "carbs_per_100g": 0, "fat_per_100g": 1, "unit": "g", "is_common": True},
        {"name": "Cottage Cheese", "category": "protein", "calories_per_100g": 98, "protein_per_100g": 11, "carbs_per_100g": 3.4, "fat_per_100g": 4.3, "unit": "g", "is_common": True},
        
        # CARBS
        {"name": "White Rice (cooked)", "category": "carb", "calories_per_100g": 130, "protein_per_100g": 2.7, "carbs_per_100g": 28, "fat_per_100g": 0.3, "unit": "g", "is_common": True},
        {"name": "Brown Rice (cooked)", "category": "carb", "calories_per_100g": 112, "protein_per_100g": 2.6, "carbs_per_100g": 24, "fat_per_100g": 0.9, "unit": "g", "is_common": True},
        {"name": "Pasta (cooked)", "category": "carb", "calories_per_100g": 131, "protein_per_100g": 5, "carbs_per_100g": 25, "fat_per_100g": 1.1, "unit": "g", "is_common": True},
        {"name": "Oats", "category": "carb", "calories_per_100g": 389, "protein_per_100g": 17, "carbs_per_100g": 66, "fat_per_100g": 7, "unit": "g", "is_common": True},
        {"name": "Sweet Potato (cooked)", "category": "carb", "calories_per_100g": 90, "protein_per_100g": 2, "carbs_per_100g": 21, "fat_per_100g": 0.2, "unit": "g", "is_common": True},
        {"name": "Potato (boiled)", "category": "carb", "calories_per_100g": 87, "protein_per_100g": 1.9, "carbs_per_100g": 20, "fat_per_100g": 0.1, "unit": "g", "is_common": True},
        {"name": "Whole Wheat Bread", "category": "carb", "calories_per_100g": 247, "protein_per_100g": 13, "carbs_per_100g": 41, "fat_per_100g": 3.4, "unit": "g", "is_common": True},
        {"name": "Quinoa (cooked)", "category": "carb", "calories_per_100g": 120, "protein_per_100g": 4.4, "carbs_per_100g": 21, "fat_per_100g": 1.9, "unit": "g", "is_common": True},
        
        # FATS
        {"name": "Olive Oil", "category": "fat", "calories_per_100g": 884, "protein_per_100g": 0, "carbs_per_100g": 0, "fat_per_100g": 100, "unit": "ml", "is_common": True},
        {"name": "Almonds", "category": "fat", "calories_per_100g": 579, "protein_per_100g": 21, "carbs_per_100g": 22, "fat_per_100g": 50, "unit": "g", "is_common": True},
        {"name": "Peanut Butter", "category": "fat", "calories_per_100g": 588, "protein_per_100g": 25, "carbs_per_100g": 20, "fat_per_100g": 50, "unit": "g", "is_common": True},
        {"name": "Avocado", "category": "fat", "calories_per_100g": 160, "protein_per_100g": 2, "carbs_per_100g": 9, "fat_per_100g": 15, "unit": "g", "is_common": True},
        {"name": "Walnuts", "category": "fat", "calories_per_100g": 654, "protein_per_100g": 15, "carbs_per_100g": 14, "fat_per_100g": 65, "unit": "g", "is_common": True},
        
        # VEGETABLES
        {"name": "Broccoli (cooked)", "category": "vegetable", "calories_per_100g": 35, "protein_per_100g": 2.4, "carbs_per_100g": 7, "fat_per_100g": 0.4, "unit": "g", "is_common": True},
        {"name": "Spinach (cooked)", "category": "vegetable", "calories_per_100g": 23, "protein_per_100g": 3, "carbs_per_100g": 3.6, "fat_per_100g": 0.3, "unit": "g", "is_common": True},
        {"name": "Carrots (cooked)", "category": "vegetable", "calories_per_100g": 35, "protein_per_100g": 0.8, "carbs_per_100g": 8, "fat_per_100g": 0.2, "unit": "g", "is_common": True},
        {"name": "Tomato", "category": "vegetable", "calories_per_100g": 18, "protein_per_100g": 0.9, "carbs_per_100g": 3.9, "fat_per_100g": 0.2, "unit": "g", "is_common": True},
        {"name": "Cucumber", "category": "vegetable", "calories_per_100g": 16, "protein_per_100g": 0.7, "carbs_per_100g": 3.6, "fat_per_100g": 0.1, "unit": "g", "is_common": True},
        {"name": "Bell Pepper", "category": "vegetable", "calories_per_100g": 31, "protein_per_100g": 1, "carbs_per_100g": 6, "fat_per_100g": 0.3, "unit": "g", "is_common": True},
        
        # FRUITS
        {"name": "Banana", "category": "fruit", "calories_per_100g": 89, "protein_per_100g": 1.1, "carbs_per_100g": 23, "fat_per_100g": 0.3, "unit": "g", "is_common": True},
        {"name": "Apple", "category": "fruit", "calories_per_100g": 52, "protein_per_100g": 0.3, "carbs_per_100g": 14, "fat_per_100g": 0.2, "unit": "g", "is_common": True},
        {"name": "Orange", "category": "fruit", "calories_per_100g": 47, "protein_per_100g": 0.9, "carbs_per_100g": 12, "fat_per_100g": 0.1, "unit": "g", "is_common": True},
        {"name": "Strawberries", "category": "fruit", "calories_per_100g": 32, "protein_per_100g": 0.7, "carbs_per_100g": 7.7, "fat_per_100g": 0.3, "unit": "g", "is_common": True},
        {"name": "Blueberries", "category": "fruit", "calories_per_100g": 57, "protein_per_100g": 0.7, "carbs_per_100g": 14, "fat_per_100g": 0.3, "unit": "g", "is_common": True},
        
        # SNACKS
        {"name": "Protein Bar", "category": "snack", "calories_per_100g": 380, "protein_per_100g": 20, "carbs_per_100g": 45, "fat_per_100g": 12, "unit": "g", "is_common": True},
        {"name": "Dark Chocolate (70%)", "category": "snack", "calories_per_100g": 598, "protein_per_100g": 7.8, "carbs_per_100g": 46, "fat_per_100g": 43, "unit": "g", "is_common": False},
        {"name": "Rice Cakes", "category": "snack", "calories_per_100g": 387, "protein_per_100g": 8, "carbs_per_100g": 82, "fat_per_100g": 3, "unit": "g", "is_common": True},
    ]
    
    print("🌱 Seeding foods...")
    
    for food_data in foods_data:
        existing = Food.query.filter_by(name=food_data['name']).first()
        if not existing:
            food = Food(**food_data)
            db.session.add(food)
    
    db.session.commit()
    print(f"✅ {len(foods_data)} foods seeded successfully!")


if __name__ == "__main__":
    with app.app_context():
        seed_foods()