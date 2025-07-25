import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { FiUser, FiMail, FiPhone, FiMapPin, FiLock, FiEye, FiEyeOff, FiCamera, FiArrowLeft, FiUserPlus, FiCheck, FiX, FiAlertTriangle } from 'react-icons/fi';
import { adminApi } from "../api/adminApi";
import dashboardColors from "../theme/dashboardColors";

function AddAgent() {
  const [showPassword, setShowPassword] = useState(false);
  const [profileImage, setProfileImage] = useState(null);
  const [profileImageFile, setProfileImageFile] = useState(null);
  const [form, setForm] = useState({ 
    fullName: "", 
    email: "", 
    phoneNumber: "", 
    address: "", 
    password: "" 
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [validationErrors, setValidationErrors] = useState({});
  const navigate = useNavigate();

  const handleImageChange = (e) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setProfileImageFile(file);
      setProfileImage(URL.createObjectURL(file));
    }
  };

  const validateField = (name, value) => {
    const errors = {};
    
    switch (name) {
      case 'fullName':
        if (!value.trim()) {
          errors.fullName = 'Full name is required';
        } else if (value.trim().length < 2) {
          errors.fullName = 'Full name must be at least 2 characters';
        } else if (!/^[a-zA-Z\s']+$/.test(value.trim())) {
          errors.fullName = 'Full name can only contain letters, spaces, and apostrophes';
        }
        break;
        
      case 'email':
        if (!value.trim()) {
          errors.email = 'Email is required';
        } else if (!/^[a-zA-Z]([a-zA-Z0-9._-]*[a-zA-Z0-9])?@[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?\.[a-zA-Z]{2,}$/.test(value.trim())) {
          errors.email = 'Email must start with a letter (e.g., user@example.com, not 123@example.com)';
        } else if (value.trim().length > 254) {
          errors.email = 'Email address is too long (maximum 254 characters)';
        }
        break;
        
      case 'phoneNumber':
        if (!value.trim()) {
          errors.phoneNumber = 'Phone number is required';
        } else if (!/^61[0-9]{7}$/.test(value.replace(/\s+/g, ''))) {
          errors.phoneNumber = 'Phone number must start with 61 and be exactly 9 digits total (e.g., 614123456)';
        }
        break;
        
      case 'address':
        if (!value.trim()) {
          errors.address = 'Address is required';
        } else if (value.trim().length < 4) {
          errors.address = 'Address must be at least 4 characters';
        } else if (value.trim().length > 200) {
          errors.address = 'Address is too long (maximum 200 characters)';
        } else if (!/^[a-zA-Z0-9\s,.-]+$/.test(value.trim())) {
          errors.address = 'Address can only contain letters, numbers, spaces, commas, periods, and hyphens';
        }
        break;
        
      case 'password':
        if (!value) {
          errors.password = 'Password is required';
        } else if (value.length < 8) {
          errors.password = 'Password must be at least 8 characters';
        } else if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(value)) {
          errors.password = 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
        }
        break;
        
      default:
        break;
    }
    
    return errors;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm({ ...form, [name]: value });
    
    // Clear validation error for this field when user starts typing
    if (validationErrors[name]) {
      setValidationErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[name];
        return newErrors;
      });
    }
    
    // Real-time validation for phone number and email formatting
    if (name === 'phoneNumber' || name === 'email') {
      const fieldErrors = validateField(name, value);
      if (Object.keys(fieldErrors).length > 0) {
        setValidationErrors(prev => ({ ...prev, ...fieldErrors }));
      }
    }
  };

  const validateForm = () => {
    const errors = {};
    
    Object.keys(form).forEach(key => {
      const fieldErrors = validateField(key, form[key]);
      Object.assign(errors, fieldErrors);
    });
    
    return errors;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");
    
    // Validate all fields
    const errors = validateForm();
    if (Object.keys(errors).length > 0) {
      setValidationErrors(errors);
      setError("Please fix the validation errors before submitting.");
      return;
    }
    
    // Clear any existing errors
    setValidationErrors({});
    setError("");
    
    setLoading(true);
    
    try {
      const formData = new FormData();
      Object.keys(form).forEach(key => {
        formData.append(key, form[key]);
      });
      
      if (profileImageFile) {
        formData.append('image', profileImageFile);
      }
      
      const response = await axios.post(adminApi.createAgent, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          'Authorization': `Bearer ${localStorage.getItem('authToken')}`
        }
      });
      
      setSuccess("Agent created successfully!");
      setTimeout(() => {
        navigate("/dashboard/agent-management");
      }, 2000);
    } catch (error) {
      console.error("Failed to create agent", error);
      setError(error.response?.data?.message || "Failed to create agent. Please try again.");
    } finally {
      setLoading(false);
    }
  };

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
              <h1 className="text-3xl font-bold bg-gradient-to-r bg-clip-text text-transparent" style={{ backgroundImage: dashboardColors.gradient.primary }}>Add New Agent</h1>
              <p className="mt-2 flex items-center gap-2" style={{ color: dashboardColors.text.secondary }}>
                <FiUserPlus className="w-4 h-4" />
                Create a new agent profile for your organization
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
              Click the camera icon to upload a profile picture
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
                      borderColor: validationErrors.fullName ? dashboardColors.status.error : dashboardColors.border.light,
                      backgroundColor: dashboardColors.background.white,
                      boxShadow: dashboardColors.shadow.sm
                    }}
                    required
                  />
                  <FiUser className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5" style={{ color: dashboardColors.text.muted }} />
                </div>
                {validationErrors.fullName && (
                  <div className="flex items-center gap-2 text-sm" style={{ color: dashboardColors.status.error }}>
                    <FiAlertTriangle className="w-4 h-4" />
                    <span>{validationErrors.fullName}</span>
                  </div>
                )}
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
                      borderColor: validationErrors.email ? dashboardColors.status.error : dashboardColors.border.light,
                      backgroundColor: dashboardColors.background.white,
                      boxShadow: dashboardColors.shadow.sm
                    }}
                    required
                  />
                  <FiMail className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5" style={{ color: dashboardColors.text.muted }} />
                </div>
                {validationErrors.email && (
                  <div className="flex items-center gap-2 text-sm" style={{ color: dashboardColors.status.error }}>
                    <FiAlertTriangle className="w-4 h-4" />
                    <span>{validationErrors.email}</span>
                  </div>
                )}
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-sm font-semibold flex items-center gap-2" style={{ color: dashboardColors.text.primary }}>
                  <FiPhone className="w-4 h-4" />
                  Phone Number * (Must start with 61, 9 digits total)
                </label>
                <div className="relative">
                  <input 
                    name="phoneNumber" 
                    type="tel" 
                    placeholder="614123456" 
                    value={form.phoneNumber} 
                    onChange={handleChange} 
                    className="w-full pl-12 pr-4 py-3 rounded-xl border transition-all duration-200 focus:outline-none focus:ring-2 focus:border-transparent" 
                    style={{ 
                      borderColor: validationErrors.phoneNumber ? dashboardColors.status.error : dashboardColors.border.light,
                      backgroundColor: dashboardColors.background.white,
                      boxShadow: dashboardColors.shadow.sm
                    }}
                    required
                  />
                  <FiPhone className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5" style={{ color: dashboardColors.text.muted }} />
                </div>
                {validationErrors.phoneNumber && (
                  <div className="flex items-center gap-2 text-sm" style={{ color: dashboardColors.status.error }}>
                    <FiAlertTriangle className="w-4 h-4" />
                    <span>{validationErrors.phoneNumber}</span>
                  </div>
                )}
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
                    placeholder="Enter full address" 
                    value={form.address} 
                    onChange={handleChange} 
                    className="w-full pl-12 pr-4 py-3 rounded-xl border transition-all duration-200 focus:outline-none focus:ring-2 focus:border-transparent" 
                    style={{ 
                      borderColor: validationErrors.address ? dashboardColors.status.error : dashboardColors.border.light,
                      backgroundColor: dashboardColors.background.white,
                      boxShadow: dashboardColors.shadow.sm
                    }}
                    required
                  />
                  <FiMapPin className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5" style={{ color: dashboardColors.text.muted }} />
                </div>
                {validationErrors.address && (
                  <div className="flex items-center gap-2 text-sm" style={{ color: dashboardColors.status.error }}>
                    <FiAlertTriangle className="w-4 h-4" />
                    <span>{validationErrors.address}</span>
                  </div>
                )}
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-semibold flex items-center gap-2" style={{ color: dashboardColors.text.primary }}>
                <FiLock className="w-4 h-4" />
                Password * (Min 8 chars, 1 uppercase, 1 lowercase, 1 number)
              </label>
              <div className="relative">
                <input 
                  name="password" 
                  type={showPassword ? "text" : "password"} 
                  placeholder="Enter secure password" 
                  value={form.password} 
                  onChange={handleChange} 
                  className="w-full pl-12 pr-12 py-3 rounded-xl border transition-all duration-200 focus:outline-none focus:ring-2 focus:border-transparent" 
                  style={{ 
                    borderColor: validationErrors.password ? dashboardColors.status.error : dashboardColors.border.light,
                    backgroundColor: dashboardColors.background.white,
                    boxShadow: dashboardColors.shadow.sm
                  }}
                  required
                />
                <FiLock className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5" style={{ color: dashboardColors.text.muted }} />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 transform -translate-y-1/2 p-1 rounded-lg transition-all duration-200 hover:scale-110"
                  style={{ color: dashboardColors.primary.gold }}
                >
                  {showPassword ? (
                    <FiEyeOff className="w-5 h-5" />
                  ) : (
                    <FiEye className="w-5 h-5" />
                  )}
                </button>
              </div>
              {validationErrors.password && (
                <div className="flex items-center gap-2 text-sm" style={{ color: dashboardColors.status.error }}>
                  <FiAlertTriangle className="w-4 h-4" />
                  <span>{validationErrors.password}</span>
                </div>
              )}
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
                disabled={loading || Object.keys(validationErrors).length > 0}
                className="flex-1 py-4 px-6 rounded-xl text-white font-semibold transition-all duration-200 transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none flex items-center justify-center gap-2"
                style={{ 
                  background: (loading || Object.keys(validationErrors).length > 0) ? dashboardColors.text.muted : dashboardColors.gradient.primary,
                  boxShadow: dashboardColors.shadow.lg 
                }}
              >
                {loading ? (
                  <>
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                    Creating Agent...
                  </>
                ) : (
                  <>
                    <FiUserPlus className="w-5 h-5" />
                    Create Agent
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

export default AddAgent;