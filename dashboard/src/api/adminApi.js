const BASE_URL = 'https://zakat-flow-backend.onrender.com';
const USER_API_URL = `${BASE_URL}/api/user`;
const PAYMENT_API_URL = `${BASE_URL}/api/payments`;

export const adminApi = {
  // --- Auth Routes ---
  loginUser: `${USER_API_URL}/login`,
  logoutUser: `${USER_API_URL}/logout`,
  forceLogoutUser: `${USER_API_URL}/force-logout`,

  // --- Agent Management Routes (Admin Only) ---
  getAgents: `${USER_API_URL}/agents`,
  getAgentById: (id) => `${USER_API_URL}/agents/${id}`,
  createAgent: `${USER_API_URL}/agents`,
  updateAgent: (id) => `${USER_API_URL}/agents/${id}`,
  deleteAgent: (id) => `${USER_API_URL}/agents/${id}`,

  // --- Payment Management Routes (Admin Only) ---
  getPayments: `${PAYMENT_API_URL}/`,
};