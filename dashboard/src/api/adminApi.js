const USER_API_URL = 'http://localhost:7000/api/user';
const PAYMENT_API_URL = 'http://localhost:7000/api/payments';

export const adminApi = {
  // --- Auth Routes ---
  loginUser: `${USER_API_URL}/login`,

  // --- Agent Management Routes (Admin Only) ---
  getAgents: `${USER_API_URL}/agents`,
  getAgentById: (id) => `${USER_API_URL}/agents/${id}`,
  createAgent: `${USER_API_URL}/agents`,
  updateAgent: (id) => `${USER_API_URL}/agents/${id}`,
  deleteAgent: (id) => `${USER_API_URL}/agents/${id}`,

  // --- Payment Management Routes (Admin Only) ---
  getPayments: `${PAYMENT_API_URL}/`,
};