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
      <main className="flex-1 ml-0 lg:ml-10 p-fluid-2 xs:p-fluid-4 sm:p-fluid-6 lg:p-8 transition-all duration-300">
        <div className="space-y-fluid-4 xs:space-y-fluid-6 md:space-y-8 animate-fadeIn">
          {/* Enhanced Header */}
          <div className="relative overflow-hidden rounded-2xl xs:rounded-3xl p-fluid-4 xs:p-fluid-6 lg:p-8 mb-fluid-4 xs:mb-8" style={{ 
            background: `linear-gradient(135deg, ${dashboardColors.primary.gold}15 0%, ${dashboardColors.primary.lightGold}10 50%, ${dashboardColors.background.white} 100%)`,
            border: `1px solid ${dashboardColors.border.light}`,
            boxShadow: dashboardColors.shadow.lg
          }}>
            <div className="relative z-10">
              <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-fluid-3 xs:gap-6">
                <div className="text-center lg:text-left">
                  <div className="flex items-center justify-center lg:justify-start gap-2 xs:gap-3 mb-fluid-2 xs:mb-4">
                    <div className="w-8 h-8 xs:w-10 xs:h-10 lg:w-12 lg:h-12 rounded-lg xs:rounded-xl flex items-center justify-center" style={{ background: `linear-gradient(135deg, ${dashboardColors.primary.gold} 0%, ${dashboardColors.primary.darkGold} 100%)` }}>
                      <FaUsers className="text-white text-fluid-sm xs:text-fluid-lg lg:text-xl" />
                    </div>
                    <h1 className="text-fluid-xl xs:text-fluid-2xl sm:text-fluid-3xl lg:text-fluid-4xl xl:text-fluid-5xl font-bold bg-gradient-to-r from-yellow-600 to-yellow-800 bg-clip-text text-transparent">
                      Agent Management
                    </h1>
                  </div>
                  <p className="text-fluid-sm xs:text-fluid-base lg:text-fluid-lg leading-relaxed" style={{ color: dashboardColors.text.secondary }}>
                    Manage and monitor all Zakat collection agents with comprehensive tracking
                  </p>
                </div>
                <div className="flex flex-col items-center lg:items-end gap-2 xs:gap-4">
                  <div className="text-center lg:text-right mb-1 xs:mb-2">
                    <p className="text-fluid-xs xs:text-fluid-sm font-medium" style={{ color: dashboardColors.text.muted }}>Total Agents</p>
                    <p className="text-fluid-lg xs:text-fluid-xl lg:text-fluid-2xl font-bold" style={{ color: dashboardColors.primary.gold }}>
                      {agents.length.toLocaleString()}
                    </p>
                  </div>
                  <Link
                    to="/dashboard/add-agent"
                    className="px-fluid-2 xs:px-6 py-2 xs:py-3 rounded-lg xs:rounded-xl font-medium transition-all duration-200 hover:scale-105 hover:shadow-lg flex items-center gap-1.5 xs:gap-2 group"
                    style={{
                      background: `linear-gradient(135deg, ${dashboardColors.primary.gold} 0%, ${dashboardColors.primary.darkGold} 100%)`,
                      color: dashboardColors.background.white,
                      boxShadow: dashboardColors.shadow.md
                    }}
                  >
                    <FaUserPlus className="text-fluid-xs xs:text-fluid-sm group-hover:rotate-90 transition-transform duration-200" />
                    <span className="text-fluid-xs xs:text-fluid-sm">Add New Agent</span>
                  </Link>
                </div>
              </div>
            </div>
            {/* Decorative Elements */}
            <div className="absolute top-0 right-0 w-32 h-32 xs:w-48 xs:h-48 lg:w-64 lg:h-64 rounded-full opacity-5 transform translate-x-16 xs:translate-x-24 lg:translate-x-32 -translate-y-16 xs:-translate-y-24 lg:-translate-y-32" style={{ backgroundColor: dashboardColors.primary.gold }}></div>
            <div className="absolute bottom-0 left-0 w-24 h-24 xs:w-36 xs:h-36 lg:w-48 lg:h-48 rounded-full opacity-5 transform -translate-x-12 xs:-translate-x-18 lg:-translate-x-24 translate-y-12 xs:translate-y-18 lg:translate-y-24" style={{ backgroundColor: dashboardColors.primary.lightGold }}></div>
          </div>


          {/* Enhanced Search Bar & Bulk Actions */}
          <div className="rounded-xl xs:rounded-2xl p-fluid-2 xs:p-fluid-4 lg:p-6 transition-all duration-300 hover:shadow-lg" style={{ backgroundColor: dashboardColors.background.white, boxShadow: dashboardColors.shadow.md, border: `1px solid ${dashboardColors.border.light}` }}>
            <div className="flex flex-col lg:flex-row gap-2 xs:gap-4">
              <div className="flex-1 relative group">
                <FaSearch className="absolute left-2 xs:left-4 top-1/2 transform -translate-y-1/2 transition-colors duration-200 group-focus-within:text-blue-500 text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.muted }} />
                <input 
                  type="text" 
                  placeholder="Search agents by name, email, or phone..." 
                  value={searchTerm} 
                  onChange={(e) => setSearchTerm(e.target.value)} 
                  className="w-full pl-8 xs:pl-12 pr-2 xs:pr-4 py-2.5 xs:py-4 rounded-lg xs:rounded-xl border transition-all duration-200 focus:outline-none focus:ring-2 focus:border-blue-400 text-fluid-xs xs:text-fluid-sm" 
                  style={{ 
                    borderColor: dashboardColors.border.light, 
                    backgroundColor: dashboardColors.background.light
                  }} 
                />
              </div>
            </div>
            {selectedAgents.length > 0 && (
              <div className="mt-fluid-2 xs:mt-6 p-2 xs:p-4 rounded-lg xs:rounded-xl animate-slideDown" style={{ backgroundColor: `${dashboardColors.status.warning}15`, border: `1px solid ${dashboardColors.status.warning}30` }}>
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 xs:gap-3">
                  <div className="flex items-center gap-2 xs:gap-3">
                    <div className="w-6 h-6 xs:w-8 xs:h-8 rounded-full flex items-center justify-center" style={{ backgroundColor: dashboardColors.status.warning }}>
                      <FaUserCheck className="text-white text-fluid-xs xs:text-fluid-sm" />
                    </div>
                    <span className="font-medium text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.primary }}>
                      {selectedAgents.length} agent(s) selected
                    </span>
                  </div>
                  <button 
                    onClick={handleBulkDelete} 
                    className="flex items-center justify-center px-fluid-2 xs:px-6 py-1.5 xs:py-2 rounded-lg font-medium transition-all duration-200 hover:scale-105 hover:shadow-lg text-fluid-xs xs:text-fluid-sm" 
                    style={{ 
                      background: `linear-gradient(135deg, ${dashboardColors.status.error} 0%, #C53030 100%)`, 
                      color: dashboardColors.background.white 
                    }}
                  >
                    <FaTrash className="mr-1 xs:mr-2 text-fluid-xs xs:text-fluid-sm" /> Delete Selected
                  </button>
                </div>
              </div>
            )}
          </div>

          {/* Enhanced Agents List/Table */}
          <div className="bg-white rounded-xl xs:rounded-2xl overflow-hidden transition-all duration-300 hover:shadow-xl" style={{ boxShadow: dashboardColors.shadow.lg, border: `1px solid ${dashboardColors.border.light}` }}>
            {filteredAgents.length === 0 ? (
              <div className="text-center py-8 xs:py-12 lg:py-20 px-fluid-2 xs:px-6">
                <div className="relative">
                  <div className="w-16 h-16 xs:w-20 xs:h-20 lg:w-24 lg:h-24 mx-auto mb-fluid-2 xs:mb-4 lg:mb-6 rounded-full flex items-center justify-center" style={{ background: `linear-gradient(135deg, ${dashboardColors.primary.lightGold}20 0%, ${dashboardColors.primary.gold}10 100%)` }}>
                    <FaUsers className="w-8 h-8 xs:w-10 xs:h-10 lg:w-12 lg:h-12" style={{ color: dashboardColors.primary.gold }} />
                  </div>
                  <h3 className="text-fluid-lg xs:text-fluid-xl lg:text-fluid-2xl font-bold mb-1.5 xs:mb-2 lg:mb-3" style={{ color: dashboardColors.text.primary }}>No agents found</h3>
                  <p className="text-fluid-sm xs:text-fluid-base lg:text-fluid-lg mb-fluid-4 xs:mb-6 lg:mb-8 max-w-md mx-auto" style={{ color: dashboardColors.text.secondary }}>Looks like there are no agents matching your search criteria. Start by adding your first agent.</p>
                  <Link 
                    to="/dashboard/add-agent" 
                    className="inline-flex items-center px-fluid-3 xs:px-6 lg:px-8 py-2.5 xs:py-3 lg:py-4 rounded-lg xs:rounded-xl font-medium transition-all duration-200 hover:scale-105 hover:shadow-lg group" 
                    style={{ background: `linear-gradient(135deg, ${dashboardColors.primary.gold} 0%, ${dashboardColors.primary.darkGold} 100%)`, color: dashboardColors.background.white }}
                  >
                    <FaUserPlus className="w-4 h-4 xs:w-5 xs:h-5 mr-2 xs:mr-3 group-hover:rotate-12 transition-transform duration-200" /> 
                    <span className="text-fluid-xs xs:text-fluid-sm lg:text-fluid-base">Add Your First Agent</span>
                  </Link>
                </div>
              </div>
            ) : (
              <div className="w-full">
                {/* --- ENHANCED DESKTOP TABLE HEADER --- */}
                <div className="hidden md:grid md:grid-cols-[60px,2fr,1.5fr,1.5fr,100px] gap-2 xs:gap-4 py-2 xs:py-3 lg:py-4 px-fluid-2 xs:px-4 lg:px-6 text-left border-b" style={{ backgroundColor: `${dashboardColors.primary.lightGold}08`, color: dashboardColors.text.primary, borderColor: dashboardColors.border.light }}>
                  <div className="flex items-center">
                    <input 
                      type="checkbox" 
                      checked={selectedAgents.length > 0 && selectedAgents.length === filteredAgents.length} 
                      onChange={handleSelectAll} 
                      className="w-3.5 h-3.5 xs:w-4 xs:h-4 rounded border-2 transition-all duration-200" 
                      style={{ borderColor: dashboardColors.border.medium, accentColor: dashboardColors.primary.gold }} 
                    />
                  </div>
                  <div className="font-semibold text-fluid-xs xs:text-fluid-sm uppercase tracking-wide" style={{ color: dashboardColors.text.primary }}>Agent</div>
                  <div className="font-semibold text-fluid-xs xs:text-fluid-sm uppercase tracking-wide" style={{ color: dashboardColors.text.primary }}>Contact</div>
                  <div className="font-semibold text-fluid-xs xs:text-fluid-sm uppercase tracking-wide" style={{ color: dashboardColors.text.primary }}>Address</div>
                  <div className="font-semibold text-fluid-xs xs:text-fluid-sm uppercase tracking-wide text-center" style={{ color: dashboardColors.text.primary }}>Actions</div>
                </div>

                {/* --- ENHANCED AGENT LIST (CARDS ON MOBILE, TABLE ROWS ON DESKTOP) --- */}
                <div className="divide-y md:divide-y-0" style={{ borderColor: dashboardColors.border.light }}>
                  {filteredAgents.map((agent, index) => (
                    <div 
                      key={agent._id} 
                      className="block md:grid md:grid-cols-[60px,2fr,1.5fr,1.5fr,100px] md:gap-2 xs:md:gap-4 md:items-center py-fluid-2 xs:py-fluid-4 lg:py-6 px-fluid-2 xs:px-fluid-4 lg:px-6 transition-all duration-300 hover:shadow-md group animate-slideUp" 
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
                              className="w-4 h-4 xs:w-5 xs:h-5 rounded border-2 transition-all duration-200" 
                              style={{ borderColor: dashboardColors.border.medium, accentColor: dashboardColors.primary.gold }} 
                            />
                            <div className="ml-2 xs:ml-4 flex items-center">
                              <div className="w-10 h-10 xs:w-12 xs:h-12 rounded-lg xs:rounded-xl overflow-hidden shadow-md transition-transform duration-200 group-hover:scale-105" style={{ background: `linear-gradient(135deg, ${dashboardColors.primary.lightGold} 0%, ${dashboardColors.primary.gold} 100%)` }}>
                                {agent.profileImage || agent.profileImageUrl || agent.image ? (
                                  <img src={agent.profileImage || agent.profileImageUrl || agent.image} alt={agent.fullName} className="w-full h-full object-cover" />
                                ) : (
                                  <div className="w-full h-full flex items-center justify-center font-bold text-white text-fluid-sm xs:text-fluid-lg">
                                    {agent.fullName?.charAt(0)?.toUpperCase() || 'A'}
                                  </div>
                                )}
                              </div>
                              <div className="ml-2 xs:ml-3">
                                <div className="font-semibold text-fluid-sm xs:text-fluid-base lg:text-fluid-lg" style={{ color: dashboardColors.text.primary }}>{agent.fullName || 'N/A'}</div>
                                <div className="text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.secondary }}>{agent.email || 'No email'}</div>
                              </div>
                            </div>
                          </div>
                          <div className="flex items-center gap-1 xs:gap-2">
                            <Link 
                              to={`/dashboard/edit-agent/${agent._id}`} 
                              className="p-2 xs:p-3 rounded-lg xs:rounded-xl transition-all duration-200 hover:scale-110 hover:shadow-md" 
                              style={{ color: dashboardColors.primary.gold, backgroundColor: `${dashboardColors.primary.lightGold}20` }}
                            >
                              <FaEdit className="text-fluid-xs xs:text-fluid-sm" />
                            </Link>
                            <button 
                              onClick={() => handleDeleteClick(agent)} 
                              className="p-2 xs:p-3 rounded-lg xs:rounded-xl transition-all duration-200 hover:scale-110 hover:shadow-md" 
                              style={{ color: dashboardColors.status.error, backgroundColor: `${dashboardColors.status.error}20` }}
                            >
                              <FaTrash className="text-fluid-xs xs:text-fluid-sm" />
                            </button>
                          </div>
                        </div>
                        <div className="mt-fluid-2 xs:mt-6 space-y-2 xs:space-y-3 pl-2 xs:pl-4 border-l-2" style={{ borderColor: dashboardColors.primary.lightGold }}>
                          <div className="flex justify-between items-center py-1.5 xs:py-2 px-2 xs:px-3 rounded-lg" style={{ backgroundColor: dashboardColors.background.light }}>
                            <span className="font-medium text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.secondary }}>Phone</span>
                            <span className="font-medium text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.primary }}>{agent.phoneNumber || agent.phone || 'N/A'}</span>
                          </div>
                          <div className="flex justify-between items-center py-1.5 xs:py-2 px-2 xs:px-3 rounded-lg" style={{ backgroundColor: dashboardColors.background.light }}>
                            <span className="font-medium text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.secondary }}>Address</span>
                            <span className="text-right font-medium text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.primary }}>{agent.address || 'N/A'}</span>
                          </div>
                        </div>
                      </div>

                      {/* == ENHANCED DESKTOP TABLE ROW VIEW == */}
                      <div className="hidden md:flex items-center">
                        <input 
                          type="checkbox" 
                          checked={selectedAgents.includes(agent._id)} 
                          onChange={() => handleSelectAgent(agent._id)} 
                          className="w-3.5 h-3.5 xs:w-4 xs:h-4 rounded border-2 transition-all duration-200" 
                          style={{ borderColor: dashboardColors.border.medium, accentColor: dashboardColors.primary.gold }} 
                        />
                      </div>
                      <div className="hidden md:flex items-center">
                        <div className="w-9 h-9 xs:w-10 xs:h-10 lg:w-11 lg:h-11 rounded-lg xs:rounded-xl overflow-hidden shadow-md mr-2 xs:mr-3 lg:mr-4 transition-transform duration-200 group-hover:scale-105" style={{ background: `linear-gradient(135deg, ${dashboardColors.primary.lightGold} 0%, ${dashboardColors.primary.gold} 100%)` }}>
                          {agent.profileImage || agent.profileImageUrl || agent.image ? (
                            <img src={agent.profileImage || agent.profileImageUrl || agent.image} alt={agent.fullName} className="w-full h-full object-cover" />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center font-bold text-white text-fluid-xs xs:text-fluid-sm">
                              {agent.fullName?.charAt(0)?.toUpperCase() || 'A'}
                            </div>
                          )}
                        </div>
                        <div>
                          <div className="font-semibold text-fluid-xs xs:text-fluid-sm lg:text-fluid-base" style={{ color: dashboardColors.text.primary }}>{agent.fullName || 'N/A'}</div>
                          <div className="text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.secondary }}>{agent.email || 'No email'}</div>
                        </div>
                      </div>
                      <div className="hidden md:block">
                        <div className="font-medium text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.primary }}>{agent.phoneNumber || agent.phone || 'N/A'}</div>
                      </div>
                      <div className="hidden md:block">
                        <div className="font-medium text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.secondary }}>{agent.address || 'N/A'}</div>
                      </div>
                      <div className="hidden md:flex items-center justify-center gap-2 xs:gap-3">
                        <Link 
                          to={`/dashboard/edit-agent/${agent._id}`} 
                          className="p-2 xs:p-2.5 rounded-lg xs:rounded-xl transition-all duration-200 hover:scale-110 hover:shadow-md" 
                          style={{ 
                            color: dashboardColors.primary.gold, 
                            backgroundColor: `${dashboardColors.primary.lightGold}20`,
                            border: `1px solid ${dashboardColors.primary.lightGold}40`
                          }} 
                          title="Edit Agent"
                        >
                          <FaEdit className="text-fluid-xs xs:text-fluid-sm" />
                        </Link>
                        <button 
                          onClick={() => handleDeleteClick(agent)} 
                          className="p-2 xs:p-2.5 rounded-lg xs:rounded-xl transition-all duration-200 hover:scale-110 hover:shadow-md" 
                          style={{ 
                            color: dashboardColors.status.error, 
                            backgroundColor: `${dashboardColors.status.error}20`,
                            border: `1px solid ${dashboardColors.status.error}40`
                          }} 
                          title="Delete Agent"
                        >
                          <FaTrash className="text-fluid-xs xs:text-fluid-sm" />
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
          <div className="bg-white rounded-xl xs:rounded-2xl p-fluid-2 xs:p-fluid-4 lg:p-6 max-w-sm xs:max-w-md w-full mx-2 xs:mx-4 animate-slideUp" style={{ boxShadow: dashboardColors.shadow.xl }}>
            <div className="text-center">
              <div className="w-12 h-12 xs:w-14 xs:h-14 lg:w-16 lg:h-16 mx-auto mb-2 xs:mb-3 lg:mb-4 rounded-full bg-red-100 flex items-center justify-center">
                <FaTrash className="w-6 h-6 xs:w-7 xs:h-7 lg:w-8 lg:h-8 text-red-600" />
              </div>
              <h3 className="text-fluid-sm xs:text-fluid-base lg:text-fluid-lg font-semibold mb-1 xs:mb-1.5 lg:mb-2" style={{ color: dashboardColors.text.primary }}>
                {bulkDeleteMode ? 'Delete Selected Agents' : 'Delete Agent'}
              </h3>
              <p className="mb-fluid-3 xs:mb-4 lg:mb-6 text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.secondary }}>
                {bulkDeleteMode ? `Are you sure you want to delete ${selectedAgents.length} selected agent(s)? This action cannot be undone.` : `Are you sure you want to delete ${agentToDelete?.fullName}? This action cannot be undone.`}
              </p>
              <div className="flex gap-2 xs:gap-3 justify-center">
                <button onClick={() => setShowDeleteModal(false)} className="flex-1 py-2 xs:py-2.5 px-2 xs:px-4 rounded-lg font-medium transition-colors text-fluid-xs xs:text-fluid-sm" style={{ backgroundColor: dashboardColors.background.light, color: dashboardColors.text.secondary, border: `1px solid ${dashboardColors.border.medium}` }}>Cancel</button>
                <button onClick={confirmDelete} className="flex-1 py-2 xs:py-2.5 px-2 xs:px-4 rounded-lg text-white font-medium transition-colors hover:opacity-90 text-fluid-xs xs:text-fluid-sm" style={{ backgroundColor: dashboardColors.status.error }}>Delete</button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default AgentManagement;