import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { adminApi } from '../api/adminApi';
import { Link, useNavigate } from 'react-router-dom';
import Sidebar from './Sidebar';
import dashboardColors from '../theme/dashboardColors';
import { FaUsers, FaUserPlus, FaSearch, FaEdit, FaTrash, FaDownload, FaUserCheck } from 'react-icons/fa';

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
        const data = response.data.data || response.data || [];
        setAgents(Array.isArray(data) ? data : []);
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
    setBulkDeleteMode(false);
    setShowDeleteModal(true);
  };

  const handleBulkDelete = () => {
    if (selectedAgents.length === 0) return;
    setBulkDeleteMode(true);
    setShowDeleteModal(true);
  };

  const confirmDelete = async () => {
    try {
      const idsToDelete = bulkDeleteMode ? selectedAgents : [agentToDelete._id];
      await Promise.all(
        idsToDelete.map(id =>
          axios.delete(adminApi.deleteAgent(id), {
            headers: { 'Authorization': `Bearer ${localStorage.getItem('authToken')}` }
          })
        )
      );
      setAgents(agents.filter(agent => !idsToDelete.includes(agent._id)));
    } catch (error) {
      console.error('Failed to delete agent(s)', error);
      alert('Failed to delete agent(s). Please try again.');
    } finally {
      setShowDeleteModal(false);
      setAgentToDelete(null);
      setSelectedAgents([]);
      setBulkDeleteMode(false);
    }
  };

  const filteredAgents = agents.filter(agent =>
    agent.fullName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    agent.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    agent.phone?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return (
      <>
        <Sidebar />
        <main className="flex-1 lg:ml-10 p-6">
          <div className="flex items-center justify-center h-64">
            <div className="text-center">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 mx-auto mb-4" style={{ borderColor: dashboardColors.primary.gold }}></div>
              <span className="ml-3 text-lg" style={{ color: dashboardColors.text.secondary }}>Loading agents...</span>
            </div>
          </div>
        </main>
      </>
    );
  }

  if (error) {
    return (
      <>
        <Sidebar />
        <main className="flex-1 lg:ml-10 p-6">
          <div className="text-center p-8">
            <div className="p-6 rounded-xl" style={{ backgroundColor: dashboardColors.status.error, color: dashboardColors.background.white }}>
              <h3 className="text-lg font-semibold mb-2">Error Loading Agents</h3>
              <p>{error}</p>
            </div>
          </div>
        </main>
      </>
    );
  }

  const summaryCards = [
    { title: "Total Agents", value: agents.length.toLocaleString(), icon: <FaUsers />, gradient: dashboardColors.gradient.primary },
    { title: "Active Agents", value: agents.filter(agent => agent.status === 'active').length.toLocaleString(), icon: <FaUserCheck />, gradient: dashboardColors.primary.darkGold },
    { title: "New This Month", value: "12", icon: <FaUserPlus />, gradient: dashboardColors.primary.gold }
  ];

  return (
    <>
      <Sidebar />
      <main className="flex-1 ml-0 lg:ml-10 p-4 sm:p-6 transition-all duration-300">
        <div className="space-y-6 md:space-y-8 animate-fadeIn">
          {/* Header */}
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            <div>
              <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold mb-2 text-yellow-700 bg-gradient-to-r from-yellow-600 to-yellow-800 bg-clip-text text-transparent">
                Agent Management
              </h1>
              <p className="text-base sm:text-lg" style={{ color: dashboardColors.text.secondary }}>
                Manage and monitor all Zakat collection agents
              </p>
            </div>
            <div className="flex flex-wrap gap-3 self-start lg:self-center">
              <Link
                to="/dashboard/add-agent"
                className="flex items-center px-6 py-2 rounded-xl font-medium transition-all duration-200 hover:scale-105"
                style={{ backgroundColor: dashboardColors.primary.gold, color: dashboardColors.background.white, boxShadow: dashboardColors.shadow.md }}
              >
                <FaUserPlus className="mr-2" />
                <span>Add Agent</span>
              </Link>
            </div>
          </div>

          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
            {summaryCards.map((card, index) => (
              <div key={index} className="relative overflow-hidden rounded-2xl p-6 transition-all duration-300 hover:scale-105 hover:shadow-2xl animate-slideUp group cursor-pointer" style={{ background: card.gradient, boxShadow: dashboardColors.shadow.lg, animationDelay: `${index * 100}ms` }}>
                <div className="relative z-10">
                  <div className="p-3 inline-block rounded-xl" style={{ backgroundColor: 'rgba(255,255,255,0.2)' }}>
                    <span className="text-2xl text-white group-hover:scale-110 transition-transform duration-200">{card.icon}</span>
                  </div>
                  <h3 className="text-white/90 text-sm font-medium mt-4 mb-2">{card.title}</h3>
                  <p className="text-white text-3xl font-bold group-hover:scale-105 transition-transform duration-200">{card.value}</p>
                </div>
                <div className="absolute top-0 right-0 w-32 h-32 rounded-full opacity-10 transform translate-x-16 -translate-y-8" style={{ backgroundColor: dashboardColors.background.white }}></div>
              </div>
            ))}
          </div>

          {/* Search Bar & Bulk Actions */}
          <div className="rounded-2xl p-4 sm:p-6 transition-all duration-300" style={{ backgroundColor: dashboardColors.background.white, boxShadow: dashboardColors.shadow.md }}>
            <div className="flex-1 relative">
              <FaSearch className="absolute left-4 top-1/2 transform -translate-y-1/2" style={{ color: dashboardColors.text.muted }} />
              <input type="text" placeholder="Search agents by name, email, or phone..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className="w-full pl-12 pr-4 py-3 rounded-xl border transition-all duration-200 focus:outline-none focus:ring-2" style={{ borderColor: dashboardColors.border.light, focusRingColor: dashboardColors.primary.lightGold }} />
            </div>
            {selectedAgents.length > 0 && (
              <div className="mt-4 p-4 rounded-xl" style={{ backgroundColor: dashboardColors.background.light }}>
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                  <span className="font-medium text-center sm:text-left" style={{ color: dashboardColors.text.primary }}>
                    {selectedAgents.length} agent(s) selected
                  </span>
                  <button onClick={handleBulkDelete} className="w-full sm:w-auto flex items-center justify-center px-4 py-2 rounded-lg font-medium transition-colors" style={{ backgroundColor: dashboardColors.status.error, color: dashboardColors.background.white }}>
                    <FaTrash className="mr-2" /> Delete Selected
                  </button>
                </div>
              </div>
            )}
          </div>

          {/* Agents List/Table */}
          <div className="bg-white rounded-xl overflow-hidden" style={{ boxShadow: dashboardColors.shadow.lg }}>
            {filteredAgents.length === 0 ? (
              <div className="text-center py-16 px-6">
                <FaUsers className="w-16 h-16 mx-auto mb-4" style={{ color: dashboardColors.text.muted }} />
                <h3 className="text-xl font-medium mb-2" style={{ color: dashboardColors.text.primary }}>No agents found</h3>
                <p className="mb-6" style={{ color: dashboardColors.text.secondary }}>Looks like there are no agents matching your search.</p>
                <Link to="/dashboard/add-agent" className="inline-flex items-center px-6 py-2 rounded-lg text-white font-medium transition-transform hover:scale-105" style={{ background: dashboardColors.gradient.primary }}>
                  <FaUserPlus className="w-4 h-4 mr-2" /> Add Agent
                </Link>
              </div>
            ) : (
              <div className="w-full">
                {/* --- DESKTOP TABLE HEADER --- */}
                <div className="hidden md:grid md:grid-cols-[60px,2fr,1.5fr,1.5fr,100px] gap-4 py-3 px-6 text-left" style={{ backgroundColor: dashboardColors.background.light, color: dashboardColors.text.primary }}>
                  <div className="flex items-center">
                    <input type="checkbox" checked={selectedAgents.length > 0 && selectedAgents.length === filteredAgents.length} onChange={handleSelectAll} className="w-4 h-4 rounded border-2" style={{ borderColor: dashboardColors.border.medium, accentColor: dashboardColors.primary.gold }} />
                  </div>
                  <div className="font-medium text-sm">Agent</div>
                  <div className="font-medium text-sm">Contact</div>
                  <div className="font-medium text-sm">Address</div>
                  <div className="font-medium text-sm text-center">Actions</div>
                </div>

                {/* --- AGENT LIST (CARDS ON MOBILE, TABLE ROWS ON DESKTOP) --- */}
                <div className="divide-y md:divide-y-0" style={{ borderColor: dashboardColors.border.light }}>
                  {filteredAgents.map(agent => (
                    <div key={agent._id} className="block md:grid md:grid-cols-[60px,2fr,1.5fr,1.5fr,100px] md:gap-4 md:items-center py-4 px-6 transition-all duration-200 hover:bg-gray-50">

                      {/* == MOBILE CARD VIEW == */}
                      <div className="md:hidden">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center">
                            <input type="checkbox" checked={selectedAgents.includes(agent._id)} onChange={() => handleSelectAgent(agent._id)} className="w-5 h-5 rounded border-2" style={{ borderColor: dashboardColors.border.medium, accentColor: dashboardColors.primary.gold }} />
                            <div className="ml-4 flex items-center">
                              <div className="w-11 h-11 rounded-full bg-gray-200 flex items-center justify-center font-bold text-gray-600 overflow-hidden">
                                {agent.profileImage || agent.profileImageUrl || agent.image ? (<img src={agent.profileImage || agent.profileImageUrl || agent.image} alt={agent.fullName} className="w-full h-full object-cover" />) : (agent.fullName?.charAt(0)?.toUpperCase() || 'A')}
                              </div>
                              <div className="ml-3">
                                <div className="font-medium" style={{ color: dashboardColors.text.primary }}>{agent.fullName || 'N/A'}</div>
                                <div className="text-sm" style={{ color: dashboardColors.text.secondary }}>{agent.email || 'No email'}</div>
                              </div>
                            </div>
                          </div>
                          <div className="flex items-center gap-1">
                            <Link to={`/dashboard/edit-agent/${agent._id}`} className="p-2 rounded-lg hover:bg-gray-200" style={{ color: dashboardColors.primary.gold }}><FaEdit /></Link>
                            <button onClick={() => handleDeleteClick(agent)} className="p-2 rounded-lg hover:bg-red-100" style={{ color: dashboardColors.status.error }}><FaTrash /></button>
                          </div>
                        </div>
                        <div className="mt-4 space-y-2 pl-2 border-l-2" style={{ borderColor: dashboardColors.border.light }}>
                          <div className="flex justify-between text-sm ml-4">
                            <span className="font-medium" style={{ color: dashboardColors.text.secondary }}>Phone</span>
                            <span style={{ color: dashboardColors.text.primary }}>{agent.phoneNumber || agent.phone || 'N/A'}</span>
                          </div>
                          <div className="flex justify-between text-sm ml-4">
                            <span className="font-medium" style={{ color: dashboardColors.text.secondary }}>Address</span>
                            <span className="text-right" style={{ color: dashboardColors.text.primary }}>{agent.address || 'N/A'}</span>
                          </div>
                        </div>
                      </div>

                      {/* == DESKTOP TABLE ROW VIEW == */}
                      <div className="hidden md:flex items-center">
                        <input type="checkbox" checked={selectedAgents.includes(agent._id)} onChange={() => handleSelectAgent(agent._id)} className="w-4 h-4 rounded border-2" style={{ borderColor: dashboardColors.border.medium, accentColor: dashboardColors.primary.gold }} />
                      </div>
                      <div className="hidden md:flex items-center">
                        <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center font-bold text-gray-600 overflow-hidden mr-3">
                          {agent.profileImage || agent.profileImageUrl || agent.image ? (<img src={agent.profileImage || agent.profileImageUrl || agent.image} alt={agent.fullName} className="w-full h-full object-cover" />) : (agent.fullName?.charAt(0)?.toUpperCase() || 'A')}
                        </div>
                        <div>
                          <div className="font-medium" style={{ color: dashboardColors.text.primary }}>{agent.fullName || 'N/A'}</div>
                          <div className="text-sm" style={{ color: dashboardColors.text.secondary }}>{agent.email || 'No email'}</div>
                        </div>
                      </div>
                      <div className="hidden md:block text-sm" style={{ color: dashboardColors.text.primary }}>{agent.phoneNumber || agent.phone || 'N/A'}</div>
                      <div className="hidden md:block text-sm" style={{ color: dashboardColors.text.secondary }}>{agent.address || 'N/A'}</div>
                      <div className="hidden md:flex items-center justify-center gap-2">
                        <Link to={`/dashboard/edit-agent/${agent._id}`} className="p-2 rounded-lg transition-all duration-200 hover:scale-110" style={{ color: dashboardColors.primary.gold, backgroundColor: dashboardColors.background.light }} title="Edit Agent"><FaEdit /></Link>
                        <button onClick={() => handleDeleteClick(agent)} className="p-2 rounded-lg transition-all duration-200 hover:scale-110" style={{ color: dashboardColors.status.error, backgroundColor: '#FEE2E2' }} title="Delete Agent"><FaTrash /></button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </main>

      {/* Delete Confirmation Modal */}
      {showDeleteModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 animate-fadeIn">
          <div className="bg-white rounded-2xl p-6 max-w-md w-full mx-4 animate-slideUp" style={{ boxShadow: dashboardColors.shadow.xl }}>
            <div className="text-center">
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-red-100 flex items-center justify-center">
                <FaTrash className="w-8 h-8 text-red-600" />
              </div>
              <h3 className="text-lg font-semibold mb-2" style={{ color: dashboardColors.text.primary }}>
                {bulkDeleteMode ? 'Delete Selected Agents' : 'Delete Agent'}
              </h3>
              <p className="mb-6" style={{ color: dashboardColors.text.secondary }}>
                {bulkDeleteMode ? `Are you sure you want to delete ${selectedAgents.length} selected agent(s)? This action cannot be undone.` : `Are you sure you want to delete ${agentToDelete?.fullName}? This action cannot be undone.`}
              </p>
              <div className="flex gap-3 justify-center">
                <button onClick={() => setShowDeleteModal(false)} className="flex-1 py-2.5 px-4 rounded-lg font-medium transition-colors" style={{ backgroundColor: dashboardColors.background.light, color: dashboardColors.text.secondary, border: `1px solid ${dashboardColors.border.medium}` }}>Cancel</button>
                <button onClick={confirmDelete} className="flex-1 py-2.5 px-4 rounded-lg text-white font-medium transition-colors hover:opacity-90" style={{ backgroundColor: dashboardColors.status.error }}>Delete</button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default AgentManagement;