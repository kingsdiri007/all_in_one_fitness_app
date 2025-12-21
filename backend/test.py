import psycopg2

# Liste des mots de passe possibles
passwords_to_try = ["password", "postgres", "admin", "root", "123456","amin123+++"]

print("Test de connexion avec l'utilisateur postgres...")

for pwd in passwords_to_try:
    try:
        conn = psycopg2.connect(
            host="localhost",
            port=5432,
            database="postgres",  # database par défaut
            user="postgres",      # utilisateur par défaut
            password=pwd
        )
        print(f"✅ CONNEXION RÉUSSIE avec le mot de passe: {pwd}")
        conn.close()
        break
    except Exception as e:
        print(f"❌ Échec avec '{pwd}'")

print("\nSi aucun mot de passe ne marche, tu devras réinitialiser le mot de passe PostgreSQL.")