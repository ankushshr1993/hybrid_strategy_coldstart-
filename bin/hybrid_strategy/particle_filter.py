import numpy as np

def particle_optimization(nodes, particles=1000, iterations=100, state=None, P=None):
    if state is None or P is None:
        x = np.array([[50], [20]])
        P = np.diag([np.var([data[0] for data in nodes.values()]), np.var([data[1] for data in nodes.values()])])
    else:
        x = state
        P = P
   
    best_particle = None
    best_cost = np.inf
   
    for i in range(iterations):
        samples = np.random.multivariate_normal(x.flatten(), P, particles)
        costs = np.zeros(particles)
       
        for j in range(particles):
            particle = samples[j,:].reshape(-1, 1)
            cost = 0
           
            for node, data in nodes.items():
                cpu_util = data[0]
                net_latency = data[1]
               
                A = np.array([[1, 1], [0, 1]])
                particle = np.dot(A, particle)

                Q = np.array([[0.01, 0], [0, 0.01]])
                P = np.dot(np.dot(A, P), A.T) + Q

                H = np.array([[1, 0], [0, 1]])
               
                R = np.array([[0.1, 0], [0, 0.1]])
               
                h = np.dot(H, particle)
               
                y = np.array([[cpu_util], [net_latency]]) - h
               
                H_jacobian = H
               
                S = np.dot(np.dot(H_jacobian, P), H_jacobian.T) + R
                K = np.dot(np.dot(P, H_jacobian.T), np.linalg.inv(S))
               
                particle = particle + np.dot(K, y)
                P = np.dot((np.eye(2) - np.dot(K, H_jacobian)), P)
               
                cost += np.linalg.norm(y)**2
               
            if cost < best_cost:
                best_particle = particle
                best_cost = cost
       
        x = best_particle
        P = np.cov(samples.T)
   
    predictions = {}
    for node, data in nodes.items():
        cpu_util = data[0]
        net_latency = data[1]
       
        A = np.array([[1, 1], [0, 1]])
        x = np.dot(A, x)

        Q = np.array([[0.01, 0], [0, 0.01]])
        P = np.dot(np.dot(A, P), A.T) + Q

        H = np.array([[1, 0], [0, 1]])
       
        R = np.array([[0.1, 0], [0, 0.1]])
       
        h = np.dot(H, x)
       
        node_predictions = h[0] + h[1] # try weighted average
        predictions[node] = node_predictions
   
    best_node = min(predictions, key=predictions.get)
   
    return best_node, predictions
