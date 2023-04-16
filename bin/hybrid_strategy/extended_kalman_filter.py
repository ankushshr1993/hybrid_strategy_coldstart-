import numpy as np

def extended_kalman_filter(nodes, state=None, P=None, x=None):
    dt = 1.0
    if state is None or P is None:
        x = np.array([[0], [0]])
        P = np.array([[1, 0], [0, 1]])
    else:
        x = state
        P = P
   
    predictions = {}
    predictions_list = {}
   
    for node, data in nodes.items():
        cpu_util = data[0]
        net_latency = data[1]
        A = np.array([[1, dt], [0, 1]])
        x = np.dot(A, x)
        Q = np.array([[0.01, 0], [0, 0.01]])
        P = np.dot(np.dot(A, P), A.T) + Q

        H = np.array([[1, 0], [0, 1]])
       
        R = np.array([[0.1, 0], [0, 0.1]])
       
        h = np.dot(H, x)
       
        y = np.array([[cpu_util], [net_latency]]) - h
       
        H_jacobian = H
       
        S = np.dot(np.dot(H_jacobian, P), H_jacobian.T) + R
        K = np.dot(np.dot(P, H_jacobian.T), np.linalg.inv(S))
       
        x = x + np.dot(K, y)
        P = np.dot((np.eye(2) - np.dot(K, H_jacobian)), P)

        node_predictions = np.dot(H, x)
        predictions[node] = node_predictions[0] + node_predictions[1] # try weighted average
        predictions_list[node] = node_predictions

    best_node = min(predictions, key=predictions.get)

    return best_node,predictions_list, x, P
