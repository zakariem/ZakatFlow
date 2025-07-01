const API_URL = 'http://localhost:5000/api/users';

export const adminApi = {
  createAgent: `${API_URL}/create-agent`,
  getAgents: `${API_URL}/agents`,
  getAgentById: (id) => `${API_URL}/agent/${id}`,
  updateAgent: (id) => `${API_URL}/agent/${id}`,
  deleteAgent: (id) => `${API_URL}/agent/${id}`,
  getPayments: `${API_URL}/payments`,
  getSummary: `${API_URL}/summary`,
  getAnalytics: `${API_URL}/analytics`,
  getOverview: `${API_URL}/overview`,
};