from flask import Flask, request, jsonify
from flask_cors import CORS  # 1. Add this import
import util

app = Flask(__name__)
CORS(app)  # 2. Add this line right after creating the app

# ... the rest of your routes (like /get_location_names) stay exactly the same

@app.route('/get_location_names')
def get_location_names():
    response = jsonify({
        'locations': util.get_location_names()
    })
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

@app.route('/predict_home_price', methods=['POST'])
def predict_home_price():
    total_sqft = float(request.form['total_sqft'])
    bhk = int(request.form['bhk'])
    bath = int(request.form['bath'])
    location = request.form['location']
    response = jsonify({
        'estimated_price': util.get_estimated_price(location, total_sqft, bath, bhk)
    })
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response 

if __name__ == '__main__':
    print("Starting server...")
    app.run()
