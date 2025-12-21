import os

class Config:
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL", "postgresql://amine:amin123+++@localhost:5432/fitness_app")

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "570b8907ff16cac33923d93078914e0188ac3038871a78b95a78a3b4ca653ecf")