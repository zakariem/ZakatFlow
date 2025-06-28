// API endpoints for admin dashboard

const API_BASE = 'http://localhost:7000/api'; // Adjust as needed for your backend

export const adminApi = {
  // Auth
  login: `${API_BASE}/users/login`,

  // // Profile
  // getProfile: `${API_BASE}/users/profile`,
  // updateProfile: `${API_BASE}/users/profile`,
  // deleteProfile: `${API_BASE}/users/profile`,

  // // Image Upload
  // uploadProfileImage: `${API_BASE}/users/upload`,

  // Agents (Admin Only)
  createAgent: `${API_BASE}/users/agents`,
  getAgents: `${API_BASE}/users/agents`,
  getAgentById: (id) => `${API_BASE}/users/agents/${id}`,
  updateAgent: (id) => `${API_BASE}/users/agents/${id}`,
  deleteAgent: (id) => `${API_BASE}/users/agents/${id}`,

  // Payments (Admin Only)
  getPayments: `${API_BASE}/payments`,
};

export default adminApi;
