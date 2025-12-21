from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_cors import CORS

db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()

def create_app():
    
    app = Flask(__name__)
    app.config.from_object("app.config.Config")

    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    CORS(app)

    # IMPORTANT: Cette partie doit être APRÈS init_app
    with app.app_context():
        # Import des models (nécessaire pour les migrations)
        from app import models
        
        # Import et enregistrement des blueprints
        from app.routes.auth import auth_bp
        app.register_blueprint(auth_bp)
        from app.routes.users import users_bp
        app.register_blueprint(users_bp)
    @app.route("/health")
    def health():
        return {"status": "ok"}

    @app.route("/test-routes")
    def test_routes():
        import urllib
        output = []
        for rule in app.url_map.iter_rules():
            methods = ','.join(rule.methods)
            output.append(f"{rule.endpoint}: {rule.rule} [{methods}]")
        return {"routes": output}

    return app