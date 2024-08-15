import pandas as pd
from transformers import BertTokenizer, BertModel
from sklearn.metrics.pairwise import cosine_similarity
from datetime import datetime
import torch
from sentence_transformers import SentenceTransformer, util

# Import data from data.py
from data import stop_words, known_breeds, synonym_breed_dict, gender_dict, vaccination_dict, age_dict

# Import db from firebase.py
from flask import Flask, jsonify, request
from firebase import db 

app = Flask(__name__)

# Load pre-trained SBERT model
model = SentenceTransformer('all-MiniLM-L6-v2')


def get_dogs_data():
    dogs_ref = db.collection('dogs')
    docs = dogs_ref.stream()

    dogs_list = []
    for doc in docs:
        dogs_list.append(doc.to_dict())
    
    return dogs_list


def extract_info(user_input):
    user_input_lower = user_input.lower()
    user_input_words = set(user_input_lower.split())

    # Extract breed
    breed = next((b for b in known_breeds if b in user_input_lower), None)
    if breed:
        breed = synonym_breed_dict.get(breed, breed)

    # Extract gender
    is_male = None
    for gender_term, is_male_value in gender_dict.items():
        if gender_term in user_input_lower:
            is_male = is_male_value
            break

    # Extract vaccination status
    is_vaccinated = None
    for vaccination_term, is_vaccinated_value in vaccination_dict.items():
        if vaccination_term in user_input_lower:
            is_vaccinated = is_vaccinated_value
            break

    # Check for custom or unexpected terms
    # I don't think this is necessary but anyways
    if is_vaccinated is None:
        if 'unvaxxed' in user_input_lower or 'unvaccinated' in user_input_lower:
            is_vaccinated = False
        elif 'vaccinated' in user_input_lower:
            is_vaccinated = True

    # Extract age range
    age_range = None
    for age_term, age_value in age_dict.items():
        if age_term in user_input_words:
            age_range = age_value
            break
    if not age_range:
        for word in user_input_lower.split():
            if word.isdigit():
                age_range = int(word)
                break

    # Extract traits
    traits = [word for word in user_input_lower.split() if word not in stop_words and word not in gender_dict and word not in vaccination_dict and word not in age_dict]

    print(f"User Input: {user_input}")
    print(f"Breed: {breed}")
    print(f"Gender: {is_male}")
    print(f"Vaccination: {is_vaccinated}")
    print(f"Age Range: {age_range}")
    print(f"Traits: {traits}")

    return breed, is_male, is_vaccinated, age_range, traits

# Function to calculate the similarity score based on bio
def calculate_bio_similarity(bio, traits_text):
    # Compute embeddings
    bio_embedding = model.encode(bio, convert_to_tensor=True)
    traits_embedding = model.encode(traits_text, convert_to_tensor=True)

    # Compute cosine similarity
    similarity = util.pytorch_cos_sim(bio_embedding, traits_embedding)
    return similarity.item()

def filter_and_rank_dogs(user_input, df):
    # Extract information from user input
    breed, is_male, is_vaccinated, age_range, traits = extract_info(user_input)
    # print("User Input:", user_input)
    # print(f"Extracted Info - Breed: {breed}, isMale: {is_male}, isVaccinated: {is_vaccinated}, Age Range: {age_range}, Traits: {traits}")

    # Filter by breed (if specified)
    if breed:
        df_filtered = df[df['breed'] == breed]
        print("After Breed Filter:")
        print(df_filtered)
    else:
        df_filtered = df.copy()
        print("No breed filter applied.")

    # Filter by gender (if specified)
    if is_male is not None:
        print(f"Applying Gender Filter: isMale = {is_male}")
        df_filtered = df_filtered[df_filtered['isMale'] == is_male]
        print("After Gender Filter:")
        print(df_filtered)
    else:
        print("Gender filter not applied.")

    # Filter by vaccination status (if specified)
    if is_vaccinated is not None:
        print(f"Applying Vaccination Filter: isVaccinated = {is_vaccinated}")
        df_filtered = df_filtered[df_filtered['isVaccinated'] == is_vaccinated]
        print("After Vaccination Filter:")
        print(df_filtered)
    else:
        print("Vaccination filter not applied.")

    # Filter by age range (if specified)
    if age_range is not None:
        df['birthday'] = pd.to_datetime(df['birthday'], errors='coerce')
        current_year = datetime.now().year
        if age_range == 'puppy':
            df_filtered = df_filtered[(current_year - pd.to_datetime(df_filtered['birthday']).dt.year) <= 1]
        elif age_range == 'young':
            df_filtered = df_filtered[(current_year - pd.to_datetime(df_filtered['birthday']).dt.year) <= 3]
        elif age_range == 'old':
            df_filtered = df_filtered[(current_year - pd.to_datetime(df_filtered['birthday']).dt.year) > 7]
        elif isinstance(age_range, int):
            df_filtered = df_filtered[(current_year - pd.to_datetime(df_filtered['birthday']).dt.year) == age_range]
        print("After Age Filter:")
        print(df_filtered)
    else:
        print("Age filter not applied.")

    # Check if DataFrame is empty before adding 'bio_similarity' column
    if df_filtered.empty:
        return df_filtered

    # Calculate similarity score based on traits
    traits_text = ' '.join(traits)
    df_filtered['bio_similarity'] = df_filtered['bio'].apply(lambda bio: calculate_bio_similarity(bio, traits_text))

    # Sort by similarity score
    df_filtered = df_filtered.sort_values(by='bio_similarity', ascending=False)
    return df_filtered

@app.route('/filter_dogs_sbert', methods=['POST'])
def filter_dogs():

    # Pull data from Firestore
    dogs_list = get_dogs_data()

    # Load the data
    df = pd.DataFrame(dogs_list)
    df['breed'] = df['breed'].str.lower()
    df['bio'] = df['bio'].str.lower()

    # Get user input from the request
    user_input = request.json.get('user_input', '')

    # Filter and rank dogs
    result = filter_and_rank_dogs(user_input, df)

    if 'location' in result.columns:
        result = result.drop(columns=['location'])
    
    # Get top 3 results
    top_results = result.head(3)
    
    # Convert DataFrame to JSON
    result_json = top_results.to_dict(orient='records')

    # Check if results are empty
    if not result_json:
        return jsonify({"message": "No dogs matched, Broaden your search terms."})

    print("Filtered Result:", result_json)
    
    return jsonify(result_json)

if __name__ == '__main__':
    app.run(debug=True)
