import numpy as np
def kalman_filter(nodes, state=None, P=None, x=None):
    dt = 1.0
    A = np.array([[1, dt], [0, 1]])
    H = np.array([[1, 0], [0, 1]])
    Q = np.array([[0.01, 0], [0, 0.01]])
    R = np.array([[0.1, 0], [0, 0.1]])

    if state is None or P is None:
        x = np.array([[0], [0]])
        P = np.array([[1, 0], [0, 1]])
    else:
        x = state
        P = P

    predictions = {}
    predictions_list = {}
    for node, data in nodes.items():
        x = np.dot(A, x)
        P = np.dot(np.dot(A, P), A.T) + Q

        y = np.array([[data[0]], [data[1]]])
        K = np.dot(np.dot(P, H.T), np.linalg.inv(np.dot(np.dot(H, P), H.T) + R))
        x = x + np.dot(K, (y - np.dot(H, x)))
        P = np.dot((np.eye(2) - np.dot(K, H)), P)

        node_predictions = np.dot(H, x)
        predictions[node] = node_predictions[0] + node_predictions[1] # try weighted average
        predictions_list[node] = node_predictions

    best_node = min(predictions, key=predictions.get)

    return best_node,predictions_list, x, P
