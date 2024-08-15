import firebase_admin
from firebase_admin import credentials, firestore

# Path to your service account key file
cred = credentials.Certificate('firebase-admin-key.json')

# Initialize the Firebase app
firebase_admin.initialize_app(cred)

# Now, you can use Firestore, Authentication, and other Firebase services
db = firestore.client()
