import nltk
from nltk.corpus import stopwords

# Initialize NLTK stopwords
nltk.download('stopwords')

# Define stop words
stop_words = set(stopwords.words('english'))

# Custom stop words
additional_stop_words = {
    'dog', 'dogs', 'is', 'and', 'always', 'up', 'for', 'a', 'or', 'the', 'to', 'with', 'you',
    'be', 'of', 'in', 'on', 'at', 'this', 'that', 'who', 'her', 'he', 'she',
    'his', 'them', 'there', 'here', 'when', 'where', 'how', 'are', 'has', 'was',
    'were', 'it', 'its', 'had', 'but', 'not', 'have', 'do', 'does', 'did', 'then',
    'so', 'because', 'if', 'after', 'before', 'during', 'between', 'among', 'always', 'please',
    'help', 'find', 'want', 'wants', 'looking', 'looking for', 'looking for a'
}
stop_words.update(additional_stop_words)

# List of accepted dog breeds
known_breeds = [
    'german shepherd', 'german sheperd', 'german shepard', 'golden retriever',
    'labrador retriever', 'labrador', 'lab', 'poodle', 'standard poodle',
    'miniature poodle', 'toy poodle', 'bulldog', 'bulldogge',
    'english bulldog', 'french bulldog', 'frenchie', 'beagle',
    'rottweiler', 'rottie', 'yorkshire terrier', 'yorkie', 'terrier',
    'boxer', 'dachshund', 'wiener dog', 'sausage dog', 'siberian husky',
    'husky', 'great dane', 'doberman pinscher', 'doberman', 'shih tzu',
    'shitzu', 'australian shepherd', 'aussie', 'cocker spaniel', 'chihuahua',
    'pug', 'maltese', 'border collie', 'collie', 'english mastiff', 'mastiff',
    'basset hound', 'shiba inu', 'shiba', 'bernese mountain dog', 'bernese',
    'bernese mt dog', 'dalmatian', 'dalmation', 'saint bernard', 'st bernard',
    'cavalier king charles spaniel', 'king charles spaniel', 'azkal',
    'askal', 'mixed breed', 'mutt', 'mongrel', 'chow chow', 'chowchow',
    'pit bull', 'pitbull', 'staffordshire terrier', 'american staffordshire terrier',
    'american pit bull terrier', 'pitbull mix', 'pit mix', 'pitbull terrier',
    'pit bull terrier', 'schnauzer', 'miniature schnauzer', 'giant schnauzer',
    'jack russell terrier', 'jack russell', 'jrt', 'greyhound',
    'italian greyhound', 'whippet', 'lhasa apso', 'malamute',
    'alaskan malamute', 'akita', 'akita inu', 'shar pei', 'sharpei',
    'weimaraner', 'vizsla', 'bichon frise', 'bichon', 'shihtzu', 'yorkie',
    'cane corso', 'chihuahua mix', 'maltipoo', 'yorkipoo', 'cockapoo',
    'goldendoodle', 'labradoodle', 'pekingese', 'papillon', 'tibetan mastiff',
    'tibetan terrier', 'hound', 'coonhound', 'bloodhound', 'foxhound',
    'basenji', 'brittany spaniel', 'brittany', 'australian cattle dog',
    'cattle dog', 'heeler', 'blue heeler', 'red heeler', 'border terrier',
    'norwich terrier', 'norfolk terrier', 'bull terrier', 'miniature bull terrier',
    'boston terrier', 'staffy', 'staffordshire bull terrier', 'pembroke welsh corgi',
    'corgi', 'cardigan welsh corgi', 'irish wolfhound', 'scottish terrier',
    'scottie', 'cairn terrier', 'west highland terrier', 'westie',
    'manchester terrier', 'airedale terrier', 'bedlington terrier',
    'skye terrier', 'soft coated wheaten terrier', 'wheaten terrier',
    'lakeland terrier', 'sealyham terrier', 'irish terrier', 'parson russell terrier',
    'patagonia terrier', 'alaskan klee kai', 'belgian malinois', 'malinois',
    'belgian shepherd', 'chinese crested', 'chinese crested dog',
    'bolognese', 'brussels griffon', 'griffon', 'coton de tulear',
    'dandie dinmont terrier', 'english setter', 'english springer spaniel',
    'field spaniel', 'flat coated retriever', 'gordon setter', 'harrier',
    'havanese', 'irish setter', 'italian greyhound', 'japanese chin',
    'keeshond', 'kerry blue terrier', 'komondor', 'kuvasz', 'leonberger',
    'lowchen', 'maremma sheepdog', 'mexican hairless', 'xoloitzcuintli',
    'neapolitan mastiff', 'nova scotia duck tolling retriever',
    'old english sheepdog', 'otterhound', 'petit basset griffon vendeen',
    'polish lowland sheepdog', 'portuguese water dog', 'puli',
    'redbone coonhound', 'rhodesian ridgeback', 'saluki', 'samoyed',
    'schipperke', 'scottish deerhound', 'silky terrier', 'spinone italiano',
    'sussex spaniel', 'swedish vallhund', 'tibetan mastiff',
    'welsh terrier', 'west highland white terrier', 'wheaten terrier',
    'wire fox terrier', 'xoloitzcuintli', 'yorkshire terrier',
    'azawakh', 'sloughi', 'pharaoh hound', 'ibizan hound', 'galgo',
    'afghan hound', 'borzoi', 'irish terrier', 'kangal', 'anatolian shepherd',
    'caucasian shepherd', 'karelian bear dog', 'mudi', 'puli',
    'tornjak', 'sarplaninac', 'rottweiler mix', 'pit mix', 'pit bull mix',
    'labrador mix', 'shepherd mix'
]

# Synonym breed dictionary
synonym_breed_dict = {
    'german sheperd': 'german shepherd',
    'german shepard': 'german shepherd',
    'lab': 'labrador retriever',
    'labrador': 'labrador retriever',
    'bulldogge': 'bulldog',
    'frenchie': 'french bulldog',
    'rottie': 'rottweiler',
    'yorkie': 'yorkshire terrier',
    'wiener dog': 'dachshund',
    'sausage dog': 'dachshund',
    'aussie': 'australian shepherd',
    'bernese': 'bernese mountain dog',
    'bernese mt dog': 'bernese mountain dog',
    'st bernard': 'saint bernard',
    'king charles spaniel': 'cavalier king charles spaniel',
    'azkal': 'askal',
    'mutt': 'mixed breed',
    'mongrel': 'mixed breed',
    'chowchow': 'chow chow',
    'standard poodle': 'poodle',
    'miniature poodle': 'poodle',
    'toy poodle': 'poodle',
    'pitbull': 'pit bull',
    'pitbull mix': 'pit bull',
    'pit mix': 'pit bull',
    'pitbull terrier': 'pit bull',
    'pit bull terrier': 'pit bull',
    'american staffordshire terrier': 'pit bull',
    'american pit bull terrier': 'pit bull',
    'staffy': 'staffordshire bull terrier',
    'collie': 'border collie',
    'heeler': 'australian cattle dog',
    'blue heeler': 'australian cattle dog',
    'red heeler': 'australian cattle dog',
    'cattle dog': 'australian cattle dog',
    'jrt': 'jack russell terrier',
    'foxhound': 'english foxhound',
    'irish setter': 'irish red setter',
    'shiba': 'shiba inu',
    'akita inu': 'akita',
    'whippet': 'greyhound',
    'sharpei': 'shar pei',
    'shihtzu': 'shih tzu',
    'westie': 'west highland white terrier',
    'yorkipoo': 'yorkshire terrier',
    'malti-poo': 'maltese'
}

# Dictionaries for gender, vaccination, and age-related terms
gender_dict = {
    'female': False,
    'girl': False,
    'lady': False,
    'male': True,
    'boy': True,
    'gentleman': True,
}

vaccination_dict = {
    'unvaccinated': False,
    'unvaxxed': False,
    'unvaxed': False,
    'no shots': False,
    'not vaccinated': False,
    'vaccinated': True,
    'has shots': True,
    'vaxxed': True,
    'vaxed': True,
    'inoculated': True
}

age_dict = {
    'puppy': 'puppy',
    'baby': 'puppy',
    'young': 'young',
    'old': 'old',
    'senior': 'old',
    'adult': 'adult'
}