function getBHKValue() {
  var bhkInputs = document.getElementsByName("bhk");
  for (var i = 0; i < bhkInputs.length; i++) {
    if (bhkInputs[i].checked) {
      return parseInt(bhkInputs[i].value);
    }
  }
  return -1;
}

function getBathValue() {
  var bathInputs = document.getElementsByName("bath");
  for (var i = 0; i < bathInputs.length; i++) {
    if (bathInputs[i].checked) {
      return parseInt(bathInputs[i].value);
    }
  }
  return -1;
}

function onClickedEstimatePrice() {
  console.log("Estimate price button clicked");

  var area = document.getElementById("area");
  var location = document.getElementById("uiLocations");
  var estPriceEl = document.getElementById("uiEstimatedPrice");

  var bhk = getBHKValue();
  var bath = getBathValue();

  if (!area.value || bhk === -1 || bath === -1 || !location.value) {
    estPriceEl.innerHTML = "Please fill all fields";
    return;
  }

  var url = "http://127.0.0.1:5000/predict_home_price";

  var formData = new FormData();
  formData.append("total_sqft", area.value);
  formData.append("bhk", bhk);
  formData.append("bath", bath);
  formData.append("location", location.value);

  fetch(url, {
    method: "POST",
    body: formData
  })
    .then(function (response) {
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      return response.json();
    })
    .then(function (data) {
      console.log(data);
      estPriceEl.innerHTML = data.estimated_price.toString() + " Lakh";
    })
    .catch(function (error) {
      console.error("Error estimating price:", error);
      estPriceEl.innerHTML = "Error estimating price";
    });
}

function onPageLoad() {
    console.log("Page loaded, fetching locations...");
    
    fetch("http://127.0.0.1:5000/get_location_names")
        .then(response => response.json())
        .then(data => {
            console.log("Got response data:", data);
            
            // FIXED HERE: Changed data.locations to data.location_names
            if(data && data.location_names) {
                var locations = data.location_names;
                var uiLocations = document.getElementById("uiLocations");
                
                // Clear the "Loading locations..." option
                uiLocations.innerHTML = '<option value="" disabled selected>Choose a Location</option>';
                
                // Add the new locations from your Python backend
                locations.forEach(location => {
                    var opt = document.createElement("option");
                    opt.value = location;
                    opt.textContent = location;
                    uiLocations.appendChild(opt);
                });
            }
        })
        .catch(error => console.error("Error loading locations:", error));
}