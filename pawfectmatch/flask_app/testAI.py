import requests

url = "http://127.0.0.1:5000/filter_dogs"
data = {
    "user_input": "I want a small and smart chihuahua dog"
}
response = requests.post(url, json=data)

print(response.json()) #dict of 3 or less dogs show up here, if no dogs then message

# # Print the response content
# print("Response Content:", response.text)

# # Attempt to parse as JSON if the content is not empty
# if response.text:
#     try:
#         data = response.json()
#         print("Parsed JSON:", data)
#     except ValueError as e:
#         print("Failed to parse JSON:", e)
# else:
#     print("Empty response received")
