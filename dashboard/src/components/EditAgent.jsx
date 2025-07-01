import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";
import { FiUser, FiMail, FiPhone, FiMapPin, FiCamera, FiArrowLeft, FiEdit3, FiCheck, FiX, FiInfo } from 'react-icons/fi';
import { adminApi } from "../api/adminApi";
import dashboardColors from "../theme/dashboardColors";

function EditAgent() {
  const [profileImage, setProfileImage] = useState(null);
  const [profileImageFile, setProfileImageFile] = useState(null);
  const [form, setForm] = useState({ fullName: "", email: "", phoneNumber: "", address: "" });
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState("");
  const { id } = useParams();
  const navigate = useNavigate();

  useEffect(() => {
    const fetchAgent = async () => {
      try {
        const response = await axios.get(adminApi.getAgentById(id), {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('authToken')}`
          }
        });
        const agentData = response.data && response.data.data ? response.data.data : response.data;
        setForm({
          fullName: agentData.fullName || "",
          email: agentData.email || "",
          phoneNumber: agentData.phoneNumber || agentData.phone || "",
          address: agentData.address || ""
        });
        setProfileImage(agentData.profileImage || agentData.image || agentData.profileImageUrl || null);
      } catch (err) {
        setError(err.response?.data?.message || err.message || "Failed to fetch agent data");
      } finally {
        setLoading(false);
      }
    };

    fetchAgent();
  }, [id]);

  const handleImageChange = (e) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setProfileImageFile(file);
      setProfileImage(URL.createObjectURL(file));
    }
  };

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setUpdating(true);
    setError(null);
    setSuccess("");
    
    try {
      const formData = new FormData();
      Object.keys(form).forEach(key => {
        formData.append(key, form[key]);
      });
      
      if (profileImageFile) {
        formData.append('image', profileImageFile);
      }
      
      await axios.put(adminApi.updateAgent(id), formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          'Authorization': `Bearer ${localStorage.getItem('authToken')}`
        }
      });
      
      setSuccess("Agent updated successfully!");
      setTimeout(() => {
        navigate("/dashboard/agent-management");
      }, 2000);
    } catch (error) {
      console.error("Failed to update agent", error);
      setError(error.response?.data?.message || "Failed to update agent. Please try again.");
    } finally {
      setUpdating(false);
    }
  };

  if (loading) {
    return (
      <>
        <div className="text-center p-8 rounded-2xl" style={{ backgroundColor: dashboardColors.background.white, boxShadow: dashboardColors.shadow.lg }}>
          <div className="relative w-20 h-20 mx-auto mb-6">
            <div className="absolute inset-0 rounded-full" style={{ background: dashboardColors.gradient.primary, animation: 'pulse 2s infinite' }}></div>
            <div className="absolute inset-2 rounded-full flex items-center justify-center" style={{ backgroundColor: dashboardColors.background.white }}>
              <FiEdit3 className="w-8 h-8" style={{ color: dashboardColors.primary.gold }} />
            </div>
          </div>
          <h3 className="text-xl font-semibold mb-2" style={{ color: dashboardColors.text.primary }}>Loading Agent Data</h3>
          <p style={{ color: dashboardColors.text.secondary }}>Please wait while we fetch the agent information...</p>
        </div>
      </>
    );
  }

  if (error && !loading) {
    return (
      <>
        <div className="text-center p-8 rounded-2xl" style={{ backgroundColor: dashboardColors.background.white, boxShadow: dashboardColors.shadow.lg }}>
          <div className="w-20 h-20 mx-auto mb-6 rounded-full flex items-center justify-center" style={{ backgroundColor: dashboardColors.status.error + '20' }}>
            <FiX className="w-10 h-10" style={{ color: dashboardColors.status.error }} />
          </div>
          <h3 className="text-xl font-semibold mb-2" style={{ color: dashboardColors.text.primary }}>Error Loading Agent</h3>
          <p className="mb-6" style={{ color: dashboardColors.text.secondary }}>{error}</p>
          <button 
            onClick={() => navigate(-1)}
            className="px-6 py-3 rounded-xl text-white font-semibold transition-all duration-200 hover:scale-105 flex items-center gap-2 mx-auto"
            style={{ background: dashboardColors.gradient.primary, boxShadow: dashboardColors.shadow.md }}
          >
            <FiArrowLeft className="w-5 h-5" />
            Go Back
          </button>
        </div>
      </>
    );
  }

  return (
    <>
      <div className="max-w-2xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-4 mb-6">
            <button 
              onClick={() => navigate(-1)}
              className="group p-3 rounded-xl transition-all duration-200 hover:scale-105"
              style={{ 
                backgroundColor: dashboardColors.background.light,
                boxShadow: dashboardColors.shadow.sm
              }}
            >
              <FiArrowLeft className="w-5 h-5 transition-colors duration-200 group-hover:text-opacity-70" style={{ color: dashboardColors.text.secondary }} />
            </button>
            <div className="flex-1">
              <h1 className="text-3xl font-bold bg-gradient-to-r bg-clip-text text-transparent" style={{ backgroundImage: dashboardColors.gradient.primary }}>Edit Agent</h1>
              <p className="mt-2 flex items-center gap-2" style={{ color: dashboardColors.text.secondary }}>
                <FiEdit3 className="w-4 h-4" />
                Update agent profile information
              </p>
            </div>
          </div>
        </div>

        {/* Form Card */}
        <div className="bg-white rounded-2xl p-8 transition-all duration-300 hover:shadow-xl" 
             style={{ boxShadow: dashboardColors.shadow.lg }}>
          
          {/* Success Message */}
          {success && (
            <div className="mb-6 p-4 rounded-xl flex items-center gap-3 animate-slideDown" style={{ 
              backgroundColor: dashboardColors.status.success + '20', 
              color: dashboardColors.status.success, 
              border: `1px solid ${dashboardColors.status.success}40`,
              boxShadow: dashboardColors.shadow.sm
            }}>
              <FiCheck className="w-5 h-5 flex-shrink-0" />
              <span className="font-medium">{success}</span>
            </div>
          )}

          {/* Error Message */}
          {error && (
            <div className="mb-6 p-4 rounded-xl flex items-center gap-3 animate-slideDown" style={{ 
              backgroundColor: dashboardColors.status.error + '20', 
              color: dashboardColors.status.error, 
              border: `1px solid ${dashboardColors.status.error}40`,
              boxShadow: dashboardColors.shadow.sm
            }}>
              <FiX className="w-5 h-5 flex-shrink-0" />
              <span className="font-medium">{error}</span>
            </div>
          )}

          {/* Profile Image Section */}
          <div className="flex flex-col items-center mb-8">
            <div className="relative group">
              <div className="w-36 h-36 rounded-full flex items-center justify-center overflow-hidden transition-all duration-300 group-hover:scale-105 border-4" 
                   style={{ 
                     backgroundColor: dashboardColors.background.light,
                     borderColor: dashboardColors.border.light,
                     boxShadow: dashboardColors.shadow.lg 
                   }}>
                {profileImage ? (
                  <img src={profileImage} alt="Profile Preview" className="w-full h-full object-cover" />
                ) : (
                  <FiUser className="w-16 h-16" style={{ color: dashboardColors.text.muted }} />
                )}
              </div>
              <label htmlFor="profile-upload" 
                     className="absolute bottom-2 right-2 rounded-full p-3 cursor-pointer border-4 border-white transition-all duration-200 hover:scale-110 group"
                     style={{ 
                       background: dashboardColors.gradient.primary,
                       boxShadow: dashboardColors.shadow.md 
                     }}>
                <FiCamera className="w-5 h-5 text-white transition-transform duration-200 group-hover:rotate-12" />
                <input id="profile-upload" type="file" accept="image/*" className="hidden" onChange={handleImageChange} />
              </label>
            </div>
            <p className="mt-4 text-sm flex items-center gap-2" style={{ color: dashboardColors.text.muted }}>
              <FiCamera className="w-4 h-4" />
              Click the camera icon to update profile picture
            </p>
          </div>

          {/* Form Fields */}
          <form className="space-y-6" onSubmit={handleSubmit}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-sm font-semibold flex items-center gap-2" style={{ color: dashboardColors.text.primary }}>
                  <FiUser className="w-4 h-4" />
                  Full Name *
                </label>
                <div className="relative">
                  <input 
                    name="fullName" 
                    type="text" 
                    placeholder="Enter full name" 
                    value={form.fullName} 
                    onChange={handleChange} 
                    className="w-full pl-12 pr-4 py-3 rounded-xl border transition-all duration-200 focus:outline-none focus:ring-2 focus:border-transparent" 
                    style={{ 
                      borderColor: dashboardColors.border.light,
                      backgroundColor: dashboardColors.background.white,
                      boxShadow: dashboardColors.shadow.sm
                    }}
                    required
                  />
                  <FiUser className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5" style={{ color: dashboardColors.text.muted }} />
                </div>
              </div>
              
              <div className="space-y-2">
                <label className="text-sm font-semibold flex items-center gap-2" style={{ color: dashboardColors.text.primary }}>
                  <FiMail className="w-4 h-4" />
                  Email Address *
                </label>
                <div className="relative">
                  <input 
                    name="email" 
                    type="email" 
                    placeholder="Enter email address" 
                    value={form.email} 
                    onChange={handleChange} 
                    className="w-full pl-12 pr-4 py-3 rounded-xl border transition-all duration-200 focus:outline-none focus:ring-2 focus:border-transparent" 
                    style={{ 
                      borderColor: dashboardColors.border.light,
                      backgroundColor: dashboardColors.background.white,
                      boxShadow: dashboardColors.shadow.sm
                    }}
                    required
                  />
                  <FiMail className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5" style={{ color: dashboardColors.text.muted }} />
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-sm font-semibold flex items-center gap-2" style={{ color: dashboardColors.text.primary }}>
                  <FiPhone className="w-4 h-4" />
                  Phone Number *
                </label>
                <div className="relative">
                  <input 
                    name="phoneNumber" 
                    type="tel" 
                    placeholder="Enter phone number" 
                    value={form.phoneNumber} 
                    onChange={handleChange} 
                    className="w-full pl-12 pr-4 py-3 rounded-xl border transition-all duration-200 focus:outline-none focus:ring-2 focus:border-transparent" 
                    style={{ 
                      borderColor: dashboardColors.border.light,
                      backgroundColor: dashboardColors.background.white,
                      boxShadow: dashboardColors.shadow.sm
                    }}
                    required
                  />
                  <FiPhone className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5" style={{ color: dashboardColors.text.muted }} />
                </div>
              </div>
              
              <div className="space-y-2">
                <label className="text-sm font-semibold flex items-center gap-2" style={{ color: dashboardColors.text.primary }}>
                  <FiMapPin className="w-4 h-4" />
                  Address *
                </label>
                <div className="relative">
                  <input 
                    name="address" 
                    type="text" 
                    placeholder="Enter address" 
                    value={form.address} 
                    onChange={handleChange} 
                    className="w-full pl-12 pr-4 py-3 rounded-xl border transition-all duration-200 focus:outline-none focus:ring-2 focus:border-transparent" 
                    style={{ 
                      borderColor: dashboardColors.border.light,
                      backgroundColor: dashboardColors.background.white,
                      boxShadow: dashboardColors.shadow.sm
                    }}
                    required
                  />
                  <FiMapPin className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5" style={{ color: dashboardColors.text.muted }} />
                </div>
              </div>
            </div>

            {/* Note about password */}
            <div className="p-4 rounded-xl border" style={{ 
              backgroundColor: dashboardColors.background.light,
              borderColor: dashboardColors.border.light,
              boxShadow: dashboardColors.shadow.sm
            }}>
              <div className="flex items-start gap-3">
                <FiInfo className="w-5 h-5 mt-0.5 flex-shrink-0" style={{ color: dashboardColors.primary.gold }} />
                <div>
                  <h4 className="text-sm font-semibold mb-1" style={{ color: dashboardColors.text.primary }}>Password Security Notice</h4>
                  <p className="text-sm" style={{ color: dashboardColors.text.secondary }}>
                    Password cannot be changed through this form for security reasons. Contact system administrator to reset password if needed.
                  </p>
                </div>
              </div>
            </div>
            
            {/* Submit Button */}
            <div className="flex gap-4 pt-6">
              <button 
                type="button"
                onClick={() => navigate(-1)}
                className="flex-1 py-4 px-6 rounded-xl font-semibold transition-all duration-200 hover:scale-105 flex items-center justify-center gap-2"
                style={{ 
                  color: dashboardColors.text.secondary,
                  backgroundColor: dashboardColors.background.light,
                  border: `2px solid ${dashboardColors.border.medium}`,
                  boxShadow: dashboardColors.shadow.sm
                }}
              >
                <FiArrowLeft className="w-5 h-5" />
                Cancel
              </button>
              <button 
                type="submit" 
                disabled={updating}
                className="flex-1 py-4 px-6 rounded-xl text-white font-semibold transition-all duration-200 transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none flex items-center justify-center gap-2"
                style={{ 
                  background: updating ? dashboardColors.text.muted : dashboardColors.gradient.primary,
                  boxShadow: dashboardColors.shadow.lg 
                }}
              >
                {updating ? (
                  <>
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                    Updating Agent...
                  </>
                ) : (
                  <>
                    <FiEdit3 className="w-5 h-5" />
                    Update Agent
                  </>
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </>
  );
}

export default EditAgent;