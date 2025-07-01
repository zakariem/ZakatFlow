import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { adminApi } from '../api/adminApi';
import { Link, useNavigate } from 'react-router-dom';
import Sidebar from './Sidebar';
import dashboardColors from '../theme/dashboardColors';
import { FaUsers, FaUserPlus, FaSearch, FaEdit, FaTrash, FaEye, FaUserCheck, FaFilter, FaDownload } from 'react-icons/fa';

const AgentManagement = () => {
  const [agents, setAgents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedAgents, setSelectedAgents] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [agentToDelete, setAgentToDelete] = useState(null);
  const [bulkDeleteMode, setBulkDeleteMode] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchAgents = async () => {
      try {
        const response = await axios.get(adminApi.getAgents, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('authToken')}`
          }
        });
        // Ensure agents is always an array
        let data = response.data;
        if (Array.isArray(data)) {
          setAgents(data);
        } else if (Array.isArray(data.data)) {
          setAgents(data.data);
        } else {
          setAgents([]);
        }
      } catch (err) {
        setError(err.response?.data?.message || err.message || 'Failed to fetch agents');
      } finally {
        setLoading(false);
      }
    };

    fetchAgents();
  }, []);

  const handleSelectAgent = (agentId) => {
    setSelectedAgents(prev => 
      prev.includes(agentId) 
        ? prev.filter(id => id !== agentId)
        : [...prev, agentId]
    );
  };

  const handleSelectAll = () => {
    if (selectedAgents.length === filteredAgents.length) {
      setSelectedAgents([]);
    } else {
      setSelectedAgents(filteredAgents.map(agent => agent._id));
    }
  };

  const handleDeleteClick = (agent) => {
    setAgentToDelete(agent);
    setShowDeleteModal(true);
  };

  const handleBulkDelete = () => {
    setBulkDeleteMode(true);
    setShowDeleteModal(true);
  };

  const confirmDelete = async () => {
    try {
      if (bulkDeleteMode) {
        // Delete multiple agents
        await Promise.all(
          selectedAgents.map(id => 
            axios.delete(adminApi.deleteAgent(id), {
              headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`
              }
            })
          )
        );
        setAgents(agents.filter(agent => !selectedAgents.includes(agent._id)));
        setSelectedAgents([]);
        setBulkDeleteMode(false);
      } else {
        // Delete single agent
        await axios.delete(adminApi.deleteAgent(agentToDelete._id), {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('authToken')}`
          }
        });
        setAgents(agents.filter(agent => agent._id !== agentToDelete._id));
      }
      setShowDeleteModal(false);
      setAgentToDelete(null);
    } catch (error) {
      console.error('Failed to delete agent(s)', error);
      alert('Failed to delete agent(s). Please try again.');
    }
  };

  const filteredAgents = agents.filter(agent => 
    agent.fullName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    agent.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    agent.phone?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return (
      <div className="flex min-h-screen" style={{ background: dashboardColors.background.main }}>
        <Sidebar />
        <main className="flex-1 ml-56 p-6">
          <div className="flex items-center justify-center h-64">
            <div className="text-center">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 mx-auto mb-4" style={{ borderColor: dashboardColors.primary.gold }}></div>
              <span className="ml-3 text-lg" style={{ color: dashboardColors.text.secondary }}>Loading agents...</span>
            </div>
          </div>
        </main>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex min-h-screen" style={{ background: dashboardColors.background.main }}>
        <Sidebar />
        <main className="flex-1 ml-56 p-6">
          <div className="text-center p-8">
            <div className="p-6 rounded-xl" style={{ backgroundColor: dashboardColors.status.error, color: dashboardColors.background.white }}>
              <h3 className="text-lg font-semibold mb-2">Error Loading Agents</h3>
              <p>{error}</p>
            </div>
          </div>
        </main>
      </div>
    );
  }

  const summaryCards = [
    {
      title: "Total Agents",
      value: agents.length.toLocaleString(),
      icon: <FaUsers />,
      gradient: dashboardColors.gradient.primary,
      change: "+5",
      changeType: "positive"
    },
    {
      title: "Active Agents",
      value: agents.filter(agent => agent.status === 'active').length.toLocaleString(),
      icon: <FaUserCheck />,
      gradient: dashboardColors.primary.darkGold,
      change: "+3",
      changeType: "positive"
    },
    {
      title: "New This Month",
      value: "12",
      icon: <FaUserPlus />,
      gradient: dashboardColors.primary.gold,
      change: "+12",
      changeType: "positive"
    }
  ];

  return (
    <>
      <Sidebar />
      <main className="flex-1 ml-10 p-6 transition-all duration-300">
        <div className="space-y-8 animate-fadeIn">
          {/* Header */}
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            <div>
              <h1 className="text-4xl lg:text-5xl font-bold mb-2 bg-gradient-to-r from-yellow-600 to-yellow-800 bg-clip-text text-transparent">
                Agent Management
              </h1>
              <p className="text-lg" style={{ color: dashboardColors.text.secondary }}>
                Manage and monitor all Zakat collection agents
              </p>
            </div>
            <div className="flex gap-3">
              <button 
                className="flex items-center px-4 py-2 rounded-xl transition-all duration-200 hover:scale-105"
                style={{ 
                  backgroundColor: dashboardColors.background.white, 
                  color: dashboardColors.primary.gold,
                  border: `1px solid ${dashboardColors.border.light}`,
                  boxShadow: dashboardColors.shadow.sm
                }}
              >
                <FaDownload className="mr-2" />
                Export
              </button>
              <Link
                to="/dashboard/add-agent"
                className="flex items-center px-6 py-2 rounded-xl font-medium transition-all duration-200 hover:scale-105"
                style={{ 
                  backgroundColor: dashboardColors.primary.gold, 
                  color: dashboardColors.background.white,
                  boxShadow: dashboardColors.shadow.md
                }}
              >
                <FaUserPlus className="mr-2" />
                Add New Agent
              </Link>
            </div>
          </div>

          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {summaryCards.map((card, index) => (
              <div 
                key={index}
                className="relative overflow-hidden rounded-2xl p-6 transition-all duration-300 hover:scale-105 hover:shadow-2xl animate-slideUp group cursor-pointer"
                style={{ 
                  background: card.gradient,
                  boxShadow: dashboardColors.shadow.lg,
                  animationDelay: `${index * 100}ms`
                }}
              >
                <div className="relative z-10">
                  <div className="flex items-center justify-between mb-4">
                    <div className="p-3 rounded-xl" style={{ backgroundColor: 'rgba(255,255,255,0.2)' }}>
                      <span className="text-2xl text-white group-hover:scale-110 transition-transform duration-200">
                        {card.icon}
                      </span>
                    </div>
                    <div className="text-right">
                      <span className={`text-sm px-2 py-1 rounded-full font-medium ${
                        card.changeType === 'positive' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                      }`}>
                        {card.change}
                      </span>
                    </div>
                  </div>
                  <h3 className="text-white/90 text-sm font-medium mb-2">{card.title}</h3>
                  <p className="text-white text-3xl font-bold group-hover:scale-105 transition-transform duration-200">
                    {card.value}
                  </p>
                </div>
                <div className="absolute top-0 right-0 w-32 h-32 rounded-full opacity-10 transform translate-x-16 -translate-y-8" 
                     style={{ backgroundColor: dashboardColors.background.white }}>
                </div>
              </div>
            ))}
          </div>

          {/* Search Bar */}
          <div 
            className="rounded-2xl p-6 transition-all duration-300 hover:shadow-lg animate-slideUp"
            style={{ 
              backgroundColor: dashboardColors.background.white,
              boxShadow: dashboardColors.shadow.md,
              animationDelay: '300ms'
            }}
          >
            <div className="flex flex-col lg:flex-row lg:items-center gap-4">
              <div className="flex-1 relative">
                <FaSearch className="absolute left-3 top-1/2 transform -translate-y-1/2" style={{ color: dashboardColors.text.muted }} />
                <input
                  type="text"
                  placeholder="Search agents by name, email, or phone..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full pl-10 pr-4 py-3 rounded-xl border transition-all duration-200 focus:outline-none focus:ring-2"
                  style={{ 
                    borderColor: dashboardColors.border.light,
                    focusRingColor: dashboardColors.primary.lightGold
                  }}
                />
              </div>
              
            </div>
            
            {/* Bulk Actions */}
            {selectedAgents.length > 0 && (
              <div className="mt-4 p-4 rounded-xl" style={{ backgroundColor: dashboardColors.background.light }}>
                <div className="flex items-center justify-between">
                  <span className="font-medium" style={{ color: dashboardColors.text.primary }}>
                    {selectedAgents.length} agent(s) selected
                  </span>
                  <button
                    onClick={handleBulkDelete}
                    className="flex items-center px-4 py-2 rounded-lg font-medium transition-all duration-200 hover:scale-105"
                    style={{ backgroundColor: dashboardColors.status.error, color: dashboardColors.background.white }}
                  >
                    <FaTrash className="mr-2" />
                    Delete Selected
                  </button>
                </div>
              </div>
            )}
          </div>

        {/* Agents Table */}
        <div className="bg-white rounded-xl overflow-hidden" style={{ boxShadow: dashboardColors.shadow.lg }}>
          {filteredAgents.length === 0 ? (
            <div className="text-center py-12">
              <svg className="w-16 h-16 mx-auto mb-4" style={{ color: dashboardColors.text.muted }} fill="none" stroke="currentColor" strokeWidth="1" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              <h3 className="text-lg font-medium mb-2" style={{ color: dashboardColors.text.primary }}>No agents found</h3>
              <p style={{ color: dashboardColors.text.secondary }}>Get started by adding your first agent.</p>
              <Link 
                to="/dashboard/add-agent" 
                className="inline-flex items-center px-4 py-2 mt-4 rounded-lg text-white font-medium transition-all duration-200 hover:scale-105"
                style={{ background: dashboardColors.gradient.primary }}
              >
                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
                </svg>
                Add First Agent
              </Link>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full">
                <thead style={{ backgroundColor: dashboardColors.background.light }}>
                  <tr>
                    <th className="py-4 px-6 text-left">
                      <div className="flex items-center">
                        <input
                          type="checkbox"
                          checked={selectedAgents.length === filteredAgents.length && filteredAgents.length > 0}
                          onChange={handleSelectAll}
                          className="w-4 h-4 rounded border-2 transition-colors duration-200"
                          style={{ 
                            borderColor: dashboardColors.border.medium,
                            accentColor: dashboardColors.primary.gold 
                          }}
                        />
                        <span className="ml-3 text-sm font-medium" style={{ color: dashboardColors.text.primary }}>Select All</span>
                      </div>
                    </th>
                    <th className="py-4 px-6 text-left text-sm font-medium" style={{ color: dashboardColors.text.primary }}>Agent</th>
                    <th className="py-4 px-6 text-left text-sm font-medium" style={{ color: dashboardColors.text.primary }}>Contact</th>
                    <th className="py-4 px-6 text-left text-sm font-medium" style={{ color: dashboardColors.text.primary }}>Address</th>
                    <th className="py-4 px-6 text-center text-sm font-medium" style={{ color: dashboardColors.text.primary }}>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredAgents.map((agent, index) => (
                    <tr 
                      key={agent._id} 
                      className="border-b transition-all duration-200 hover:bg-gray-50"
                      style={{ borderColor: dashboardColors.border.light }}
                    >
                      <td className="py-4 px-6">
                        <input
                          type="checkbox"
                          checked={selectedAgents.includes(agent._id)}
                          onChange={() => handleSelectAgent(agent._id)}
                          className="w-4 h-4 rounded border-2 transition-colors duration-200"
                          style={{ 
                            borderColor: dashboardColors.border.medium,
                            accentColor: dashboardColors.primary.gold 
                          }}
                        />
                      </td>
                      <td className="py-4 px-6">
                        <div className="flex items-center">
                          <div className="w-10 h-10 rounded-full bg-gradient-to-r from-blue-400 to-purple-500 flex items-center justify-center text-white font-medium mr-3 overflow-hidden">
                            {agent.profileImage || agent.profileImageUrl || agent.image ? (
                              <img
                                src={agent.profileImage || agent.profileImageUrl || agent.image}
                                alt={agent.fullName}
                                className="w-full h-full object-cover rounded-full"
                              />
                            ) : (
                              agent.fullName?.charAt(0)?.toUpperCase() || 'A'
                            )}
                          </div>
                          <div>
                            <div className="font-medium" style={{ color: dashboardColors.text.primary }}>
                              {agent.fullName || 'N/A'}
                            </div>
                            <div className="text-sm" style={{ color: dashboardColors.text.secondary }}>
                              {agent.email || 'No email'}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="py-4 px-6">
                        <div className="text-sm" style={{ color: dashboardColors.text.primary }}>
                          {agent.phoneNumber || agent.phone || 'No phone'}
                        </div>
                      </td>
                      <td className="py-4 px-6">
                        <div className="text-sm" style={{ color: dashboardColors.text.secondary }}>
                          {agent.address || 'No address'}
                        </div>
                      </td>
                      <td className="py-4 px-6">
                        <div className="flex items-center justify-center gap-2">
                          <Link 
                            to={`/dashboard/edit-agent/${agent._id}`} 
                            className="p-2 rounded-lg transition-all duration-200 hover:scale-110"
                            style={{ 
                              color: dashboardColors.primary.gold,
                              backgroundColor: dashboardColors.background.light 
                            }}
                            title="Edit Agent"
                          >
                            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.5L16.732 3.732z" />
                            </svg>
                          </Link>
                          <button 
                            onClick={() => handleDeleteClick(agent)} 
                            className="p-2 rounded-lg transition-all duration-200 hover:scale-110"
                            style={{ 
                              color: dashboardColors.status.error,
                              backgroundColor: '#FEE2E2' 
                            }}
                            title="Delete Agent"
                          >
                            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                            </svg>
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Delete Confirmation Modal */}
        {showDeleteModal && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 animate-fadeIn">
            <div className="bg-white rounded-2xl p-6 max-w-md w-full mx-4 animate-slideUp" style={{ boxShadow: dashboardColors.shadow.xl }}>
              <div className="text-center">
                <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-red-100 flex items-center justify-center">
                  <svg className="w-8 h-8 text-red-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
                  </svg>
                </div>
                <h3 className="text-lg font-semibold mb-2" style={{ color: dashboardColors.text.primary }}>
                  {bulkDeleteMode ? 'Delete Selected Agents' : 'Delete Agent'}
                </h3>
                <p className="mb-6" style={{ color: dashboardColors.text.secondary }}>
                  {bulkDeleteMode 
                    ? `Are you sure you want to delete ${selectedAgents.length} selected agent${selectedAgents.length !== 1 ? 's' : ''}? This action cannot be undone.`
                    : `Are you sure you want to delete ${agentToDelete?.fullName}? This action cannot be undone.`
                  }
                </p>
                <div className="flex gap-3">
                  <button
                    onClick={() => {
                      setShowDeleteModal(false);
                      setAgentToDelete(null);
                      setBulkDeleteMode(false);
                    }}
                    className="flex-1 py-2 px-4 rounded-lg font-medium transition-all duration-200 hover:opacity-80"
                    style={{ 
                      color: dashboardColors.text.secondary,
                      backgroundColor: dashboardColors.background.light,
                      border: `1px solid ${dashboardColors.border.medium}`
                    }}
                  >
                    Cancel
                  </button>
                  <button
                    onClick={confirmDelete}
                    className="flex-1 py-2 px-4 rounded-lg text-white font-medium transition-all duration-200 hover:opacity-90"
                    style={{ backgroundColor: dashboardColors.status.error }}
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </main>
  </>
);
};

export default AgentManagement;