import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";
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
      <div className="min-h-screen flex items-center justify-center" style={{ background: dashboardColors.background.main }}>
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 mx-auto mb-4" style={{ borderColor: dashboardColors.primary.gold }}></div>
          <p style={{ color: dashboardColors.text.secondary }}>Loading agent data...</p>
        </div>
      </div>
    );
  }

  if (error && !loading) {
    return (
      <div className="min-h-screen flex items-center justify-center" style={{ background: dashboardColors.background.main }}>
        <div className="text-center">
          <div className="text-red-500 mb-4">
            <svg className="w-16 h-16 mx-auto" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
            </svg>
          </div>
          <p className="text-red-600 mb-4">{error}</p>
          <button 
            onClick={() => navigate(-1)}
            className="px-4 py-2 rounded-lg text-white"
            style={{ background: dashboardColors.gradient.primary }}
          >
            Go Back
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen px-4 py-6 transition-all duration-500" 
         style={{ background: dashboardColors.background.main }}>
      <div className="max-w-2xl mx-auto">
        {/* Header */}
        <div className="flex items-center mb-8">
          <button 
            onClick={() => navigate(-1)} 
            className="mr-4 p-2 rounded-lg transition-all duration-200 hover:scale-110"
            style={{ 
              color: dashboardColors.text.secondary,
              backgroundColor: dashboardColors.background.white,
              boxShadow: dashboardColors.shadow.sm 
            }}
          >
            <svg width="24" height="24" fill="none" viewBox="0 0 24 24">
              <path d="M15 19l-7-7 7-7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </button>
          <h1 className="text-3xl font-bold" style={{ color: dashboardColors.text.primary }}>
            Edit Agent
          </h1>
        </div>

        {/* Form Card */}
        <div className="bg-white rounded-2xl p-8 transition-all duration-300 hover:shadow-xl" 
             style={{ boxShadow: dashboardColors.shadow.lg }}>
          
          {/* Success Message */}
          {success && (
            <div className="mb-6 p-4 rounded-lg text-sm animate-pulse" 
                 style={{ backgroundColor: '#D1FAE5', color: dashboardColors.status.success }}>
              <div className="flex items-center">
                <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                </svg>
                {success}
              </div>
            </div>
          )}

          {/* Error Message */}
          {error && (
            <div className="mb-6 p-4 rounded-lg text-sm animate-shake" 
                 style={{ backgroundColor: '#FEE2E2', color: dashboardColors.status.error }}>
              <div className="flex items-center">
                <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                </svg>
                {error}
              </div>
            </div>
          )}

          {/* Profile Image Section */}
          <div className="flex flex-col items-center mb-8">
            <div className="relative group">
              <div className="w-32 h-32 rounded-full bg-gray-100 flex items-center justify-center overflow-hidden transition-all duration-300 group-hover:scale-105" 
                   style={{ boxShadow: dashboardColors.shadow.md }}>
                {profileImage ? (
                  <img src={profileImage} alt="Profile Preview" className="w-full h-full object-cover" />
                ) : (
                  <svg width="60" height="60" fill="none" viewBox="0 0 60 60" style={{ color: dashboardColors.text.muted }}>
                    <circle cx="30" cy="30" r="28" stroke="currentColor" strokeWidth="2"/>
                    <circle cx="30" cy="24" r="8" fill="currentColor"/>
                    <path d="M30 36c-8 0-14 4-14 8v2h28v-2c0-4-6-8-14-8z" fill="currentColor"/>
                  </svg>
                )}
              </div>
              <label htmlFor="profile-upload" 
                     className="absolute bottom-2 right-2 rounded-full p-3 cursor-pointer border-4 border-white transition-all duration-200 hover:scale-110"
                     style={{ 
                       background: dashboardColors.gradient.primary,
                       boxShadow: dashboardColors.shadow.md 
                     }}>
                <svg width="20" height="20" fill="white" viewBox="0 0 20 20">
                  <path d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm8 3a1 1 0 112 0 1 1 0 01-2 0zM4 5h1.172a2 2 0 001.414-.586l.828-.828A2 2 0 018.828 3h2.344a2 2 0 011.414.586l.828.828A2 2 0 0014.828 5H16v2H4V5zm0 4h12v6a1 1 0 01-1 1H5a1 1 0 01-1-1V9zm3 2a2 2 0 114 0 2 2 0 01-4 0z" />
                </svg>
                <input id="profile-upload" type="file" accept="image/*" className="hidden" onChange={handleImageChange} />
              </label>
            </div>
            <p className="mt-3 text-sm" style={{ color: dashboardColors.text.muted }}>
              Click the camera icon to update profile picture
            </p>
          </div>

          {/* Form Fields */}
          <form className="space-y-6" onSubmit={handleSubmit}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-1">
                <label className="text-sm font-medium" style={{ color: dashboardColors.text.primary }}>
                  Full Name *
                </label>
                <input 
                  name="fullName" 
                  type="text" 
                  placeholder="Enter full name" 
                  value={form.fullName} 
                  onChange={handleChange} 
                  className="w-full px-4 py-3 rounded-lg border transition-all duration-200 focus:outline-none focus:ring-2" 
                  style={{ 
                    borderColor: dashboardColors.border.light,
                    focusRingColor: dashboardColors.primary.gold 
                  }}
                  required
                />
              </div>
              
              <div className="space-y-1">
                <label className="text-sm font-medium" style={{ color: dashboardColors.text.primary }}>
                  Email Address *
                </label>
                <input 
                  name="email" 
                  type="email" 
                  placeholder="Enter email address" 
                  value={form.email} 
                  onChange={handleChange} 
                  className="w-full px-4 py-3 rounded-lg border transition-all duration-200 focus:outline-none focus:ring-2" 
                  style={{ 
                    borderColor: dashboardColors.border.light,
                    focusRingColor: dashboardColors.primary.gold 
                  }}
                  required
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-1">
                <label className="text-sm font-medium" style={{ color: dashboardColors.text.primary }}>
                  Phone Number *
                </label>
                <input 
                  name="phoneNumber" 
                  type="tel" 
                  placeholder="Enter phone number" 
                  value={form.phoneNumber} 
                  onChange={handleChange} 
                  className="w-full px-4 py-3 rounded-lg border transition-all duration-200 focus:outline-none focus:ring-2" 
                  style={{ 
                    borderColor: dashboardColors.border.light,
                    focusRingColor: dashboardColors.primary.gold 
                  }}
                  required
                />
              </div>
              
              <div className="space-y-1">
                <label className="text-sm font-medium" style={{ color: dashboardColors.text.primary }}>
                  Address *
                </label>
                <input 
                  name="address" 
                  type="text" 
                  placeholder="Enter address" 
                  value={form.address} 
                  onChange={handleChange} 
                  className="w-full px-4 py-3 rounded-lg border transition-all duration-200 focus:outline-none focus:ring-2" 
                  style={{ 
                    borderColor: dashboardColors.border.light,
                    focusRingColor: dashboardColors.primary.gold 
                  }}
                  required
                />
              </div>
            </div>

            {/* Note about password */}
            <div className="p-4 rounded-lg" style={{ backgroundColor: dashboardColors.background.light }}>
              <div className="flex items-center">
                <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24" style={{ color: dashboardColors.primary.gold }}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <p className="text-sm" style={{ color: dashboardColors.text.secondary }}>
                  Password cannot be changed through this form for security reasons. Contact system administrator to reset password if needed.
                </p>
              </div>
            </div>
            
            {/* Submit Button */}
            <div className="flex gap-4 pt-4">
              <button 
                type="button"
                onClick={() => navigate(-1)}
                className="flex-1 py-3 px-4 rounded-lg font-semibold transition-all duration-200 hover:opacity-80"
                style={{ 
                  color: dashboardColors.text.secondary,
                  backgroundColor: dashboardColors.background.light,
                  border: `1px solid ${dashboardColors.border.medium}`
                }}
              >
                Cancel
              </button>
              <button 
                type="submit" 
                disabled={updating}
                className="flex-1 py-3 px-4 rounded-lg text-white font-semibold transition-all duration-200 transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
                style={{ 
                  background: updating ? dashboardColors.text.muted : dashboardColors.gradient.primary,
                  boxShadow: dashboardColors.shadow.md 
                }}
              >
                {updating ? (
                  <div className="flex items-center justify-center">
                    <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Updating Agent...
                  </div>
                ) : (
                  'Update Agent'
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

export default EditAgent;