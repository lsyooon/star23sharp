from typing import List
import math
import numpy as np

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

def get_cosine_distance(list1: List[float], list2: List[float]):
    """
    Calculates the cosine distance between two lists of floats.

    Parameters:
    list1 (list of float): The first list of floats.
    list2 (list of float): The second list of floats.

    Returns:
    float: The cosine distance between the two lists.
    """
    array1 = np.array(list1)
    array2 = np.array(list2)
    cosine_similarity = np.dot(array1, array2) / (np.linalg.norm(array1) * np.linalg.norm(array2))
    return 1 - cosine_similarity  # Cosine distance is 1 - cosine similarity


def get_degree_for_radius(x:float) -> float:
    return (x*180)/(math.pi*6371_000)