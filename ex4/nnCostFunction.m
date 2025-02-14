function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
X = [ones(m,1) X]; % (5000 x 401)
z2 = X * Theta1'; % (5000 x 401) * (401 x 25) --> (5000 x 25)
a2 = sigmoid(z2); % (5000 x 25)
a2 = [ones(size(a2,1),1) a2]; % (5000 x 26)

z3 = a2 * Theta2'; % (5000 x 26) * (26 x 10) --> (5000 x 10)
a3 = sigmoid(z3); % (5000 x 10)

temp = 1:num_labels;
temp = repelem(temp,m,1);
y_final = (temp == y); % (5000 x 10)

J = (1/m) * sum ( sum ( (-y_final .* log(a3) - (1-y_final) .* log(1-a3)) ));

Theta1_wo_b = Theta1(:,2:size(Theta1,2));
Theta2_wo_b = Theta2(:,2:size(Theta2,2));

Reg = (lambda/(2*m))  * (sum( sum ( Theta1_wo_b.^ 2 )) + sum( sum ( Theta2_wo_b.^ 2 ))); 
J = J +Reg;
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.

for t = 1:m,
    a1 = X(t,:); % (1 x 401)
    a1 = a1'; % As mentioned in the ex4.mlx that a1 should be colum vector
    
    z2 = Theta1 * a1; % (25 x 401) * (401 x 1) --> (25 x 1)
    a2 = sigmoid(z2); % activation for layer 2 --> (25 x 1)
    a2 = [1; a2]; % (26 x 1)
    
    z3 = Theta2 * a2; % (10 x 26) * (26 x 401) --> (10 x 1)
    a3 = sigmoid(z3); % activation for layer 3 --> (10 x 1)
    
    delta3 = a3 - y_final(t,:)'; % (10 x 1) - (10 x 1) --> (10 x 1)
    
    z2 = [1; z2]; % (26 x 1)
    delta2 = (Theta2'*delta3) .* sigmoidGradient(z2);%(26x10)*(10x1) --> 26x1
    delta2 = delta2(2:end); % 25x1
    
    Theta2_grad = Theta2_grad + (delta3 * a2'); %(10x1)*(1x26) --> (10x26)
    Theta1_grad = Theta1_grad + (delta2 * a1'); %(25x1)*(1x401) --> (25x401)
    
end

Theta2_grad = (1/m) * Theta2_grad; % (10x26)
Theta1_grad = (1/m) * Theta1_grad; % (25x401)

% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.

Theta2_grad(:, 2:end) = Theta2_grad(:, 2:end) + ((lambda/m) * Theta2(:, 2:end));
Theta1_grad(:, 2:end) = Theta1_grad(:, 2:end) + ((lambda/m) * Theta1(:, 2:end)); 
% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
