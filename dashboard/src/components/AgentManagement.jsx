import React, { useState, useEffect } from 'react';
import axiosInstance from '../utils/axiosConfig';
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
        const response = await axiosInstance.get(adminApi.getAgents);
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
          axiosInstance.delete(adminApi.deleteAgent(id))
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

 

  return (
    <>
      <Sidebar />
      <main className="flex-1 ml-0 lg:ml-10 p-4 sm:p-6 transition-all duration-300">
        <div className="space-y-6 md:space-y-8 animate-fadeIn">
          {/* Enhanced Header */}
          <div className="relative overflow-hidden rounded-3xl p-8 mb-8" style={{ 
            background: `linear-gradient(135deg, ${dashboardColors.primary.gold}15 0%, ${dashboardColors.primary.lightGold}10 50%, ${dashboardColors.background.white} 100%)`,
            border: `1px solid ${dashboardColors.border.light}`,
            boxShadow: dashboardColors.shadow.lg
          }}>
            <div className="relative z-10">
              <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
                <div className="text-center lg:text-left">
                  <div className="flex items-center justify-center lg:justify-start gap-3 mb-4">
                    <div className="w-12 h-12 rounded-xl flex items-center justify-center" style={{ background: `linear-gradient(135deg, ${dashboardColors.primary.gold} 0%, ${dashboardColors.primary.darkGold} 100%)` }}>
                      <FaUsers className="text-white text-xl" />
                    </div>
                    <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold bg-gradient-to-r from-yellow-600 to-yellow-800 bg-clip-text text-transparent">
                      Agent Management
                    </h1>
                  </div>
                  <p className="text-lg leading-relaxed" style={{ color: dashboardColors.text.secondary }}>
                    Manage and monitor all Zakat collection agents with comprehensive tracking
                  </p>
                </div>
                <div className="flex flex-col items-center lg:items-end gap-4">
                  <div className="text-center lg:text-right mb-2">
                    <p className="text-sm font-medium" style={{ color: dashboardColors.text.muted }}>Total Agents</p>
                    <p className="text-2xl font-bold" style={{ color: dashboardColors.primary.gold }}>
                      {agents.length.toLocaleString()}
                    </p>
                  </div>
                  <Link
                    to="/dashboard/add-agent"
                    className="px-6 py-3 rounded-xl font-medium transition-all duration-200 hover:scale-105 hover:shadow-lg flex items-center gap-2 group"
                    style={{
                      background: `linear-gradient(135deg, ${dashboardColors.primary.gold} 0%, ${dashboardColors.primary.darkGold} 100%)`,
                      color: dashboardColors.background.white,
                      boxShadow: dashboardColors.shadow.md
                    }}
                  >
                    <FaUserPlus className="text-sm group-hover:rotate-90 transition-transform duration-200" />
                    Add New Agent
                  </Link>
                </div>
              </div>
            </div>
            {/* Decorative Elements */}
            <div className="absolute top-0 right-0 w-64 h-64 rounded-full opacity-5 transform translate-x-32 -translate-y-32" style={{ backgroundColor: dashboardColors.primary.gold }}></div>
            <div className="absolute bottom-0 left-0 w-48 h-48 rounded-full opacity-5 transform -translate-x-24 translate-y-24" style={{ backgroundColor: dashboardColors.primary.lightGold }}></div>
          </div>


          {/* Enhanced Search Bar & Bulk Actions */}
          <div className="rounded-2xl p-6 transition-all duration-300 hover:shadow-lg" style={{ backgroundColor: dashboardColors.background.white, boxShadow: dashboardColors.shadow.md, border: `1px solid ${dashboardColors.border.light}` }}>
            <div className="flex flex-col lg:flex-row gap-4">
              <div className="flex-1 relative group">
                <FaSearch className="absolute left-4 top-1/2 transform -translate-y-1/2 transition-colors duration-200 group-focus-within:text-blue-500" style={{ color: dashboardColors.text.muted }} />
                <input 
                  type="text" 
                  placeholder="Search agents by name, email, or phone..." 
                  value={searchTerm} 
                  onChange={(e) => setSearchTerm(e.target.value)} 
                  className="w-full pl-12 pr-4 py-4 rounded-xl border transition-all duration-200 focus:outline-none focus:ring-2 focus:border-blue-400" 
                  style={{ 
                    borderColor: dashboardColors.border.light, 
                    backgroundColor: dashboardColors.background.light,
                    fontSize: '16px'
                  }} 
                />
              </div>
            </div>
            {selectedAgents.length > 0 && (
              <div className="mt-6 p-4 rounded-xl animate-slideDown" style={{ backgroundColor: `${dashboardColors.status.warning}15`, border: `1px solid ${dashboardColors.status.warning}30` }}>
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full flex items-center justify-center" style={{ backgroundColor: dashboardColors.status.warning }}>
                      <FaUserCheck className="text-white text-sm" />
                    </div>
                    <span className="font-medium" style={{ color: dashboardColors.text.primary }}>
                      {selectedAgents.length} agent(s) selected
                    </span>
                  </div>
                  <button 
                    onClick={handleBulkDelete} 
                    className="flex items-center justify-center px-6 py-2 rounded-lg font-medium transition-all duration-200 hover:scale-105 hover:shadow-lg" 
                    style={{ 
                      background: `linear-gradient(135deg, ${dashboardColors.status.error} 0%, #C53030 100%)`, 
                      color: dashboardColors.background.white 
                    }}
                  >
                    <FaTrash className="mr-2" /> Delete Selected
                  </button>
                </div>
              </div>
            )}
          </div>

          {/* Enhanced Agents List/Table */}
          <div className="bg-white rounded-2xl overflow-hidden transition-all duration-300 hover:shadow-xl" style={{ boxShadow: dashboardColors.shadow.lg, border: `1px solid ${dashboardColors.border.light}` }}>
            {filteredAgents.length === 0 ? (
              <div className="text-center py-20 px-6">
                <div className="relative">
                  <div className="w-24 h-24 mx-auto mb-6 rounded-full flex items-center justify-center" style={{ background: `linear-gradient(135deg, ${dashboardColors.primary.lightGold}20 0%, ${dashboardColors.primary.gold}10 100%)` }}>
                    <FaUsers className="w-12 h-12" style={{ color: dashboardColors.primary.gold }} />
                  </div>
                  <h3 className="text-2xl font-bold mb-3" style={{ color: dashboardColors.text.primary }}>No agents found</h3>
                  <p className="text-lg mb-8 max-w-md mx-auto" style={{ color: dashboardColors.text.secondary }}>Looks like there are no agents matching your search criteria. Start by adding your first agent.</p>
                  <Link 
                    to="/dashboard/add-agent" 
                    className="inline-flex items-center px-8 py-4 rounded-xl font-medium transition-all duration-200 hover:scale-105 hover:shadow-lg group" 
                    style={{ background: `linear-gradient(135deg, ${dashboardColors.primary.gold} 0%, ${dashboardColors.primary.darkGold} 100%)`, color: dashboardColors.background.white }}
                  >
                    <FaUserPlus className="w-5 h-5 mr-3 group-hover:rotate-12 transition-transform duration-200" /> 
                    Add Your First Agent
                  </Link>
                </div>
              </div>
            ) : (
              <div className="w-full">
                {/* --- ENHANCED DESKTOP TABLE HEADER --- */}
                <div className="hidden md:grid md:grid-cols-[60px,2fr,1.5fr,1.5fr,100px] gap-4 py-4 px-6 text-left border-b" style={{ backgroundColor: `${dashboardColors.primary.lightGold}08`, color: dashboardColors.text.primary, borderColor: dashboardColors.border.light }}>
                  <div className="flex items-center">
                    <input 
                      type="checkbox" 
                      checked={selectedAgents.length > 0 && selectedAgents.length === filteredAgents.length} 
                      onChange={handleSelectAll} 
                      className="w-4 h-4 rounded border-2 transition-all duration-200" 
                      style={{ borderColor: dashboardColors.border.medium, accentColor: dashboardColors.primary.gold }} 
                    />
                  </div>
                  <div className="font-semibold text-sm uppercase tracking-wide" style={{ color: dashboardColors.text.primary }}>Agent</div>
                  <div className="font-semibold text-sm uppercase tracking-wide" style={{ color: dashboardColors.text.primary }}>Contact</div>
                  <div className="font-semibold text-sm uppercase tracking-wide" style={{ color: dashboardColors.text.primary }}>Address</div>
                  <div className="font-semibold text-sm uppercase tracking-wide text-center" style={{ color: dashboardColors.text.primary }}>Actions</div>
                </div>

                {/* --- ENHANCED AGENT LIST (CARDS ON MOBILE, TABLE ROWS ON DESKTOP) --- */}
                <div className="divide-y md:divide-y-0" style={{ borderColor: dashboardColors.border.light }}>
                  {filteredAgents.map((agent, index) => (
                    <div 
                      key={agent._id} 
                      className="block md:grid md:grid-cols-[60px,2fr,1.5fr,1.5fr,100px] md:gap-4 md:items-center py-6 px-6 transition-all duration-300 hover:shadow-md group animate-slideUp" 
                      style={{ 
                        animationDelay: `${index * 50}ms`,
                        backgroundColor: selectedAgents.includes(agent._id) ? `${dashboardColors.primary.lightGold}10` : 'transparent'
                      }}
                      onMouseEnter={(e) => {
                        if (!selectedAgents.includes(agent._id)) {
                          e.currentTarget.style.backgroundColor = `${dashboardColors.background.light}`;
                        }
                      }}
                      onMouseLeave={(e) => {
                        if (!selectedAgents.includes(agent._id)) {
                          e.currentTarget.style.backgroundColor = 'transparent';
                        }
                      }}
                    >

                      {/* == ENHANCED MOBILE CARD VIEW == */}
                      <div className="md:hidden">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center">
                            <input 
                              type="checkbox" 
                              checked={selectedAgents.includes(agent._id)} 
                              onChange={() => handleSelectAgent(agent._id)} 
                              className="w-5 h-5 rounded border-2 transition-all duration-200" 
                              style={{ borderColor: dashboardColors.border.medium, accentColor: dashboardColors.primary.gold }} 
                            />
                            <div className="ml-4 flex items-center">
                              <div className="w-12 h-12 rounded-xl overflow-hidden shadow-md transition-transform duration-200 group-hover:scale-105" style={{ background: `linear-gradient(135deg, ${dashboardColors.primary.lightGold} 0%, ${dashboardColors.primary.gold} 100%)` }}>
                                {agent.profileImage || agent.profileImageUrl || agent.image ? (
                                  <img src={agent.profileImage || agent.profileImageUrl || agent.image} alt={agent.fullName} className="w-full h-full object-cover" />
                                ) : (
                                  <div className="w-full h-full flex items-center justify-center font-bold text-white text-lg">
                                    {agent.fullName?.charAt(0)?.toUpperCase() || 'A'}
                                  </div>
                                )}
                              </div>
                              <div className="ml-3">
                                <div className="font-semibold text-lg" style={{ color: dashboardColors.text.primary }}>{agent.fullName || 'N/A'}</div>
                                <div className="text-sm" style={{ color: dashboardColors.text.secondary }}>{agent.email || 'No email'}</div>
                              </div>
                            </div>
                          </div>
                          <div className="flex items-center gap-2">
                            <Link 
                              to={`/dashboard/edit-agent/${agent._id}`} 
                              className="p-3 rounded-xl transition-all duration-200 hover:scale-110 hover:shadow-md" 
                              style={{ color: dashboardColors.primary.gold, backgroundColor: `${dashboardColors.primary.lightGold}20` }}
                            >
                              <FaEdit className="text-sm" />
                            </Link>
                            <button 
                              onClick={() => handleDeleteClick(agent)} 
                              className="p-3 rounded-xl transition-all duration-200 hover:scale-110 hover:shadow-md" 
                              style={{ color: dashboardColors.status.error, backgroundColor: `${dashboardColors.status.error}20` }}
                            >
                              <FaTrash className="text-sm" />
                            </button>
                          </div>
                        </div>
                        <div className="mt-6 space-y-3 pl-4 border-l-2" style={{ borderColor: dashboardColors.primary.lightGold }}>
                          <div className="flex justify-between items-center py-2 px-3 rounded-lg" style={{ backgroundColor: dashboardColors.background.light }}>
                            <span className="font-medium text-sm" style={{ color: dashboardColors.text.secondary }}>Phone</span>
                            <span className="font-medium" style={{ color: dashboardColors.text.primary }}>{agent.phoneNumber || agent.phone || 'N/A'}</span>
                          </div>
                          <div className="flex justify-between items-center py-2 px-3 rounded-lg" style={{ backgroundColor: dashboardColors.background.light }}>
                            <span className="font-medium text-sm" style={{ color: dashboardColors.text.secondary }}>Address</span>
                            <span className="text-right font-medium" style={{ color: dashboardColors.text.primary }}>{agent.address || 'N/A'}</span>
                          </div>
                        </div>
                      </div>

                      {/* == ENHANCED DESKTOP TABLE ROW VIEW == */}
                      <div className="hidden md:flex items-center">
                        <input 
                          type="checkbox" 
                          checked={selectedAgents.includes(agent._id)} 
                          onChange={() => handleSelectAgent(agent._id)} 
                          className="w-4 h-4 rounded border-2 transition-all duration-200" 
                          style={{ borderColor: dashboardColors.border.medium, accentColor: dashboardColors.primary.gold }} 
                        />
                      </div>
                      <div className="hidden md:flex items-center">
                        <div className="w-11 h-11 rounded-xl overflow-hidden shadow-md mr-4 transition-transform duration-200 group-hover:scale-105" style={{ background: `linear-gradient(135deg, ${dashboardColors.primary.lightGold} 0%, ${dashboardColors.primary.gold} 100%)` }}>
                          {agent.profileImage || agent.profileImageUrl || agent.image ? (
                            <img src={agent.profileImage || agent.profileImageUrl || agent.image} alt={agent.fullName} className="w-full h-full object-cover" />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center font-bold text-white">
                              {agent.fullName?.charAt(0)?.toUpperCase() || 'A'}
                            </div>
                          )}
                        </div>
                        <div>
                          <div className="font-semibold text-base" style={{ color: dashboardColors.text.primary }}>{agent.fullName || 'N/A'}</div>
                          <div className="text-sm" style={{ color: dashboardColors.text.secondary }}>{agent.email || 'No email'}</div>
                        </div>
                      </div>
                      <div className="hidden md:block">
                        <div className="font-medium" style={{ color: dashboardColors.text.primary }}>{agent.phoneNumber || agent.phone || 'N/A'}</div>
                      </div>
                      <div className="hidden md:block">
                        <div className="font-medium" style={{ color: dashboardColors.text.secondary }}>{agent.address || 'N/A'}</div>
                      </div>
                      <div className="hidden md:flex items-center justify-center gap-3">
                        <Link 
                          to={`/dashboard/edit-agent/${agent._id}`} 
                          className="p-2.5 rounded-xl transition-all duration-200 hover:scale-110 hover:shadow-md" 
                          style={{ 
                            color: dashboardColors.primary.gold, 
                            backgroundColor: `${dashboardColors.primary.lightGold}20`,
                            border: `1px solid ${dashboardColors.primary.lightGold}40`
                          }} 
                          title="Edit Agent"
                        >
                          <FaEdit className="text-sm" />
                        </Link>
                        <button 
                          onClick={() => handleDeleteClick(agent)} 
                          className="p-2.5 rounded-xl transition-all duration-200 hover:scale-110 hover:shadow-md" 
                          style={{ 
                            color: dashboardColors.status.error, 
                            backgroundColor: `${dashboardColors.status.error}20`,
                            border: `1px solid ${dashboardColors.status.error}40`
                          }} 
                          title="Delete Agent"
                        >
                          <FaTrash className="text-sm" />
                        </button>
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