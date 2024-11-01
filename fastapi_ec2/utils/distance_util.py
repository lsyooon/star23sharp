from typing import List
import math
import numpy as np

RADIUS_EARTH = 6371_000 #meters

def get_l2_distance(list1: List[float], list2: List[float]):
    """
    Calculates the L2 distance between two lists of floats.

    Parameters:
    list1 (list of float): The first list of floats.
    list2 (list of float): The second list of floats.

    Returns:
    float: The L2 distance between the two lists.
    """
    array1 = np.array(list1)
    array2 = np.array(list2)
    return np.linalg.norm(array1 - array2)

def get_cosine_distance(list1: List[float], list2: List[float], dtype=np.float32):
    """
    Calculates the cosine distance between two lists of floats.

    Parameters:
    list1 (list of float): The first list of floats.
    list2 (list of float): The second list of floats.

    Returns:
    float: The cosine distance between the two lists.
    """
    array1 = np.array(list1, dtype= dtype)
    array2 = np.array(list2, dtype= dtype)
    cosine_similarity = np.dot(array1, array2) / (np.linalg.norm(array1) * np.linalg.norm(array2))
    #Precision Error 로 인해 invalid 한 cosine 값이 발생하는 것을 방지
    cosine_similarity = max(-1, min(1, cosine_similarity))
    
    return 1 - cosine_similarity  # Cosine distance is 1 - cosine similarity

def get_degree_from_distance(distance: float) -> float:
    return (distance * 180) / (math.pi * RADIUS_EARTH)

def get_distance_from_degree(degree: float) -> float:
    return (degree * math.pi * RADIUS_EARTH) / 180

def convert_lat_lng_to_xyz(lat:float, lng:float, radius=RADIUS_EARTH) -> List[float]:
    # Convert latitude and longitude from degrees to radians
    lat_rad = math.radians(lat)
    lng_rad = math.radians(lng)
    
    # Calculate Cartesian coordinates
    x = radius * math.cos(lat_rad) * math.cos(lng_rad)
    y = radius * math.cos(lat_rad) * math.sin(lng_rad)
    z = radius * math.sin(lat_rad)
    
    return [x, y, z]
