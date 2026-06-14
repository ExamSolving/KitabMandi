/// India states → cities map (sorted alphabetically within each state).
/// Used by the location picker sheet.
const Map<String, List<String>> indianCitiesByState = {
  'Andaman & Nicobar Islands': ['Port Blair'],
  'Andhra Pradesh': [
    'Anantapur', 'Bhimavaram', 'Chittoor', 'Eluru', 'Guntur',
    'Kadapa', 'Kakinada', 'Kurnool', 'Machilipatnam', 'Nellore',
    'Ongole', 'Rajahmundry', 'Rajam', 'Srikakulam', 'Tirupati',
    'Vijayawada', 'Visakhapatnam',
  ],
  'Arunachal Pradesh': ['Itanagar', 'Tawang', 'Ziro'],
  'Assam': [
    'Bongaigaon', 'Dhubri', 'Dibrugarh', 'Guwahati', 'Jorhat',
    'Lakhimpur', 'Nagaon', 'Silchar', 'Tezpur', 'Tinsukia',
  ],
  'Bihar': [
    'Arrah', 'Begusarai', 'Bhagalpur', 'Bihar Sharif', 'Chhapra',
    'Darbhanga', 'Gaya', 'Katihar', 'Munger', 'Muzaffarpur',
    'Patna', 'Purnia', 'Samastipur', 'Sasaram', 'Siwan',
  ],
  'Chandigarh': ['Chandigarh'],
  'Chhattisgarh': [
    'Ambikapur', 'Bhilai', 'Bilaspur', 'Dhamtari', 'Durg',
    'Jagdalpur', 'Korba', 'Raigarh', 'Raipur', 'Rajnandgaon',
  ],
  'Dadra & Nagar Haveli': ['Silvassa'],
  'Daman & Diu': ['Daman', 'Diu'],
  'Delhi': [
    'Connaught Place', 'Dwarka', 'East Delhi', 'Janakpuri', 'Karol Bagh',
    'Lajpat Nagar', 'New Delhi', 'North Delhi', 'Pitampura', 'Rohini',
    'Saket', 'South Delhi', 'West Delhi',
  ],
  'Goa': ['Calangute', 'Mapusa', 'Margao', 'Panaji', 'Ponda', 'Vasco da Gama'],
  'Gujarat': [
    'Ahmedabad', 'Anand', 'Bharuch', 'Bhavnagar', 'Gandhinagar',
    'Jamnagar', 'Junagadh', 'Mehsana', 'Morbi', 'Navsari',
    'Rajkot', 'Surendranagar', 'Surat', 'Vadodara', 'Valsad',
  ],
  'Haryana': [
    'Ambala', 'Bahadurgarh', 'Bhiwani', 'Faridabad', 'Gurugram',
    'Hisar', 'Jind', 'Karnal', 'Kurukshetra', 'Panchkula',
    'Panipat', 'Rohtak', 'Sirsa', 'Sonipat', 'Yamunanagar',
  ],
  'Himachal Pradesh': [
    'Baddi', 'Bilaspur', 'Dharamsala', 'Kullu', 'Manali',
    'Mandi', 'Nahan', 'Palampur', 'Shimla', 'Solan',
  ],
  'Jammu & Kashmir': [
    'Anantnag', 'Baramulla', 'Jammu', 'Kathua', 'Punch',
    'Rajouri', 'Sopore', 'Srinagar', 'Udhampur',
  ],
  'Jharkhand': [
    'Bokaro', 'Deoghar', 'Dhanbad', 'Giridih', 'Hazaribagh',
    'Jamshedpur', 'Kothagudem', 'Medininagar', 'Phusro', 'Ramgarh', 'Ranchi',
  ],
  'Karnataka': [
    'Ballari', 'Belagavi', 'Bengaluru', 'Bidar', 'Davanagere',
    'Dharwad', 'Hassan', 'Hubli', 'Kalaburagi', 'Mangaluru',
    'Mysuru', 'Raichur', 'Shimoga', 'Tumkur', 'Udupi', 'Vijayapura',
  ],
  'Kerala': [
    'Alappuzha', 'Idukki', 'Kannur', 'Kasaragod', 'Kochi',
    'Kollam', 'Kottayam', 'Kozhikode', 'Malappuram', 'Palakkad',
    'Pathanamthitta', 'Thiruvananthapuram', 'Thrissur', 'Wayanad',
  ],
  'Ladakh': ['Kargil', 'Leh'],
  'Lakshadweep': ['Kavaratti'],
  'Madhya Pradesh': [
    'Bhind', 'Bhopal', 'Burhanpur', 'Chhindwara', 'Dewas',
    'Gwalior', 'Indore', 'Jabalpur', 'Khandwa', 'Murwara',
    'Ratlam', 'Rewa', 'Sagar', 'Satna', 'Singrauli', 'Ujjain',
  ],
  'Maharashtra': [
    'Ahmednagar', 'Akola', 'Amravati', 'Aurangabad', 'Chandrapur',
    'Dhule', 'Dombivli', 'Jalgaon', 'Kalyan', 'Kolhapur',
    'Latur', 'Malegaon', 'Mumbai', 'Nagpur', 'Nanded',
    'Nashik', 'Pune', 'Solapur', 'Thane', 'Vasai', 'Virar',
  ],
  'Manipur': ['Bishnupur', 'Imphal', 'Thoubal'],
  'Meghalaya': ['Jowai', 'Shillong', 'Tura'],
  'Mizoram': ['Aizawl', 'Lunglei'],
  'Nagaland': ['Dimapur', 'Kohima'],
  'Odisha': [
    'Balasore', 'Bargarh', 'Baripada', 'Bhadrak', 'Bhubaneswar',
    'Brahmapur', 'Cuttack', 'Dhenkanal', 'Jeypore', 'Jharsuguda',
    'Koraput', 'Puri', 'Rayagada', 'Rourkela', 'Sambalpur',
  ],
  'Puducherry': ['Karaikal', 'Mahe', 'Puducherry'],
  'Punjab': [
    'Amritsar', 'Batala', 'Bathinda', 'Firozpur', 'Gurdaspur',
    'Hoshiarpur', 'Jalandhar', 'Ludhiana', 'Moga', 'Mohali',
    'Muktsar', 'Pathankot', 'Patiala', 'Phagwara', 'Sangrur',
  ],
  'Rajasthan': [
    'Ajmer', 'Alwar', 'Banswara', 'Baran', 'Barmer',
    'Bharatpur', 'Bhilwara', 'Bikaner', 'Chittorgarh', 'Hanumangarh',
    'Jaipur', 'Jhunjhunu', 'Jodhpur', 'Kota', 'Nagaur',
    'Pali', 'Sikar', 'Sri Ganganagar', 'Tonk', 'Udaipur',
  ],
  'Sikkim': ['Gangtok', 'Mangan', 'Namchi'],
  'Tamil Nadu': [
    'Chennai', 'Coimbatore', 'Dindigul', 'Erode', 'Hosur',
    'Kanchipuram', 'Karur', 'Kumarapalayam', 'Madurai', 'Nagercoil',
    'Ranipet', 'Salem', 'Sivakasi', 'Thanjavur', 'Thoothukudi',
    'Tiruchirappalli', 'Tirunelveli', 'Tiruppur', 'Udhagamandalam', 'Vellore',
  ],
  'Telangana': [
    'Adilabad', 'Hyderabad', 'Jagtial', 'Karimnagar', 'Khammam',
    'Kothagudem', 'Mahbubnagar', 'Mancherial', 'Miryalaguda', 'Nalgonda',
    'Nizamabad', 'Ramagundam', 'Siddipet', 'Suryapet', 'Warangal',
  ],
  'Tripura': ['Agartala', 'Dharmanagar', 'Udaipur'],
  'Uttar Pradesh': [
    'Agra', 'Aligarh', 'Bareilly', 'Budaun', 'Etawah',
    'Faizabad', 'Firozabad', 'Ghaziabad', 'Gorakhpur', 'Hapur',
    'Hathras', 'Jhansi', 'Kanpur', 'Loni', 'Lucknow',
    'Mainpuri', 'Mathura', 'Meerut', 'Moradabad', 'Muzaffarnagar',
    'Noida', 'Prayagraj', 'Rampur', 'Saharanpur', 'Varanasi',
  ],
  'Uttarakhand': [
    'Almora', 'Dehradun', 'Haridwar', 'Haldwani', 'Kashipur',
    'Mussoorie', 'Nainital', 'Rishikesh', 'Roorkee', 'Rudrapur',
  ],
  'West Bengal': [
    'Asansol', 'Bankura', 'Bardhaman', 'Birbhum', 'Durgapur',
    'Habra', 'Haldia', 'Howrah', 'Jalpaiguri', 'Kolkata',
    'Krishnanagar', 'Malda', 'Baharampur', 'Medinipur', 'New Town',
    'Purulia', 'Raiganj', 'Ranaghat', 'Siliguri',
  ],
};

List<String> get indianStates =>
    indianCitiesByState.keys.toList()..sort();

/// Search across all states and cities — returns list of [city, state] pairs.
List<({String city, String state})> searchAllLocations(String query) {
  final q = query.toLowerCase().trim();
  if (q.isEmpty) return [];
  final results = <({String city, String state})>[];
  for (final entry in indianCitiesByState.entries) {
    for (final city in entry.value) {
      if (city.toLowerCase().contains(q)) {
        results.add((city: city, state: entry.key));
      }
    }
  }
  return results;
}
