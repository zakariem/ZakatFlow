import React, { useState, useEffect } from "react";
import axiosInstance from "../utils/axiosConfig";
import { adminApi } from "../api/adminApi";
import { dashboardColors } from "../theme/dashboardColors";
import { FaCrown, FaMoneyBillWave, FaCalendarAlt, FaChartLine, FaHome } from "react-icons/fa";
import { Line, Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const Overview = () => {
  const [payments, setPayments] = useState([]);
  const [agents, setAgents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [paymentsRes, agentsRes] = await Promise.all([
          axiosInstance.get(adminApi.getPayments),
          axiosInstance.get(adminApi.getAgents)
        ]);
        let paymentsData = paymentsRes.data;
        let agentsData = agentsRes.data;
        setPayments(Array.isArray(paymentsData) ? paymentsData : paymentsData.data || []);
        setAgents(Array.isArray(agentsData) ? agentsData : agentsData.data || []);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  // Calculate summary values
  const totalPayments = payments.length;
  const totalAmount = payments.reduce((sum, p) => sum + (parseFloat(p.actualZakatAmount) || parseFloat(p.amount) || 0), 0);
  const today = new Date();
  const todaysPayments = payments.filter(p => {
    const paidAt = new Date(p.paidAt || p.date);
    return paidAt.getFullYear() === today.getFullYear() &&
      paidAt.getMonth() === today.getMonth() &&
      paidAt.getDate() === today.getDate();
  });
  const todaysPaymentsCount = todaysPayments.length;
  const todaysAmount = todaysPayments.reduce((sum, p) => sum + (parseFloat(p.actualZakatAmount) || parseFloat(p.amount) || 0), 0);

  // 14-day trend
  const last14Days = Array.from({ length: 14 }, (_, i) => {
    const date = new Date();
    date.setDate(date.getDate() - i);
    return date;
  }).reverse();

  // Filter out payments with invalid dates
  const validPayments = payments.filter(p => {
    const paidAt = new Date(p.paidAt || p.date);
    return paidAt instanceof Date && !isNaN(paidAt);
  });

  const dailyPayments = last14Days.map(date => {
    const label = date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    const filtered = validPayments.filter(p => {
      const paidAt = new Date(p.paidAt || p.date);
      return paidAt.getDate() === date.getDate() &&
             paidAt.getMonth() === date.getMonth() &&
             paidAt.getFullYear() === date.getFullYear();
    });
    return {
      date: label,
      amount: filtered.reduce((sum, p) => sum + (parseFloat(p.actualZakatAmount) || parseFloat(p.amount) || 0), 0),
      count: filtered.length
    };
  });



  // Top 5 agents by total collection
  const topAgents = [...(Array.isArray(agents) ? agents : [])]
    .filter(a => a && a.fullName)
    .sort((a, b) => (b.totalDonation || 0) - (a.totalDonation || 0))
    .slice(0, 5);
  const topAgentLabels = topAgents.map(a => a.fullName);
  const topAgentData = topAgents.map(a => a.totalDonation || 0);

  // Chart options
  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top',
      },
      tooltip: {
        mode: 'index',
        intersect: false,
        callbacks: {
          label: function(context) {
            let label = context.dataset.label || '';
            if (label) label += ': ';
            if (context.parsed.y !== null) label += '$' + context.parsed.y.toLocaleString();
            return label;
          }
        }
      },
    },
    interaction: {
      mode: 'nearest',
      axis: 'x',
      intersect: false
    },
  };

  const amountChartData = {
    labels: dailyPayments.map(day => day.date),
    datasets: [
      {
        label: 'Daily Amount ($)',
        data: dailyPayments.map(day => day.amount),
        borderColor: dashboardColors.primary.gold,
        backgroundColor: 'rgba(255, 215, 64, 0.2)',
        pointBackgroundColor: dashboardColors.primary.gold,
        pointBorderColor: dashboardColors.primary.gold,
        tension: 0.4,
        fill: true,
      },
    ],
  };

  const paymentsChartData = {
    labels: dailyPayments.map(day => day.date),
    datasets: [
      {
        label: 'Number of Payments',
        data: dailyPayments.map(day => day.count),
        backgroundColor: dashboardColors.primary.lightGold,
        borderColor: dashboardColors.primary.gold,
        borderWidth: 2,
        borderRadius: 6,
        maxBarThickness: 24,
      },
    ],
  };



  const agentBarChartData = {
    labels: topAgentLabels,
    datasets: [
      {
        label: 'Total Collected ($)',
        data: topAgentData,
        backgroundColor: dashboardColors.primary.gold,
        borderColor: dashboardColors.primary.lightGold,
        borderWidth: 2,
        borderRadius: 6,
        maxBarThickness: 32,
      },
    ],
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2" style={{ borderColor: dashboardColors.primary.gold }}></div>
        <span className="ml-3 text-lg" style={{ color: dashboardColors.text.secondary }}>Loading dashboard...</span>
      </div>
    );
  }
  
  if (error) {
    return (
      <div className="text-center p-8">
        <div className="p-6 rounded-xl" style={{ backgroundColor: dashboardColors.status.error, color: dashboardColors.background.white }}>
          <h3 className="text-lg font-semibold mb-2">Error Loading Data</h3>
          <p>{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-fluid-6 animate-fadeIn">
      {/* Enhanced Header with Welcome Card */}
      <div className="relative overflow-hidden rounded-2xl xs:rounded-3xl p-fluid-4 xs:p-fluid-6 lg:p-fluid-8 mb-fluid-6" style={{ 
        background: `linear-gradient(135deg, ${dashboardColors.primary.gold}15 0%, ${dashboardColors.primary.lightGold}10 50%, ${dashboardColors.background.white} 100%)`,
        border: `1px solid ${dashboardColors.border.light}`,
        boxShadow: dashboardColors.shadow.lg
      }}>
        <div className="relative z-10">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-fluid-4 lg:gap-fluid-6">
            <div className="text-center lg:text-left">
              <div className="flex items-center justify-center lg:justify-start gap-3 xs:gap-4 mb-fluid-2 xs:mb-fluid-4">
                <div className="w-10 h-10 xs:w-12 xs:h-12 lg:w-14 lg:h-14 rounded-xl flex items-center justify-center transition-all duration-300" style={{ background: dashboardColors.gradient.primary }}>
                  <FaHome className="text-white text-lg xs:text-xl lg:text-2xl" />
                </div>
                <h1 className="text-fluid-2xl xs:text-fluid-2xl lg:text-fluid-3xl xl:text-fluid-4xl font-bold bg-gradient-to-r from-yellow-600 to-yellow-800 bg-clip-text text-transparent leading-tight">
                  Dashboard Overview
                </h1>
              </div>
              <p className="text-fluid-base xs:text-fluid-lg leading-relaxed max-w-2xl" style={{ color: dashboardColors.text.secondary }}>
                Welcome back! Here's what's happening with your Zakat operations today.
              </p>
            </div>
            <div className="flex flex-col items-center lg:items-end gap-fluid-2 xs:gap-3">
              <div className="text-center lg:text-right">
                <p className="text-fluid-xs xs:text-fluid-sm font-medium" style={{ color: dashboardColors.text.muted }}>Last Updated</p>
                <p className="text-fluid-sm xs:text-fluid-base lg:text-fluid-lg font-semibold" style={{ color: dashboardColors.text.primary }}>
                  {new Date().toLocaleDateString('en-US', { 
                    weekday: 'long', 
                    year: 'numeric', 
                    month: 'long', 
                    day: 'numeric' 
                  })}
                </p>
              </div>
            </div>
          </div>
        </div>
        {/* Decorative Elements */}
        <div className="absolute top-0 right-0 w-64 h-64 rounded-full opacity-5 transform translate-x-32 -translate-y-32" style={{ backgroundColor: dashboardColors.primary.gold }}></div>
        <div className="absolute bottom-0 left-0 w-48 h-48 rounded-full opacity-5 transform -translate-x-24 translate-y-24" style={{ backgroundColor: dashboardColors.primary.lightGold }}></div>
      </div>

      {/* Enhanced Charts Grid */}
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-fluid-4 xs:gap-fluid-6 lg:gap-fluid-8">
        {[
          {
            title: "Payment Amounts Trend",
            subtitle: "Last 14 Days",
            icon: <FaChartLine className="text-xl" />,
            component: dailyPayments.every(day => day.amount === 0) ? (
              <div className="flex flex-col items-center justify-center h-full">
                <div className="w-16 h-16 rounded-full mb-4 flex items-center justify-center" style={{ backgroundColor: dashboardColors.background.light }}>
                  <FaChartLine className="text-2xl" style={{ color: dashboardColors.text.muted }} />
                </div>
                <span className="text-lg font-medium" style={{ color: dashboardColors.text.muted }}>No payment data available</span>
                <span className="text-sm" style={{ color: dashboardColors.text.light }}>for the last 14 days</span>
              </div>
            ) : (
              <Line options={chartOptions} data={amountChartData} />
            ),
            delay: "0ms"
          },
          {
            title: "Payment Count Trend",
            subtitle: "Last 14 Days",
            icon: <FaMoneyBillWave className="text-xl" />,
            component: dailyPayments.every(day => day.count === 0) ? (
              <div className="flex flex-col items-center justify-center h-full">
                <div className="w-16 h-16 rounded-full mb-4 flex items-center justify-center" style={{ backgroundColor: dashboardColors.background.light }}>
                  <FaMoneyBillWave className="text-2xl" style={{ color: dashboardColors.text.muted }} />
                </div>
                <span className="text-lg font-medium" style={{ color: dashboardColors.text.muted }}>No payment count data</span>
                <span className="text-sm" style={{ color: dashboardColors.text.light }}>for the last 14 days</span>
              </div>
            ) : (
              <Bar options={chartOptions} data={paymentsChartData} />
            ),
            delay: "100ms"
          },

          {
            title: "Top Performing Agents",
            subtitle: "By Collection Amount",
            icon: <FaCrown className="text-xl" />,
            component: topAgentLabels.length === 0 || topAgentData.every(v => v === 0) ? (
              <div className="flex flex-col items-center justify-center h-full">
                <div className="w-16 h-16 rounded-full mb-4 flex items-center justify-center" style={{ backgroundColor: dashboardColors.background.light }}>
                  <FaCrown className="text-2xl" style={{ color: dashboardColors.text.muted }} />
                </div>
                <span className="text-lg font-medium" style={{ color: dashboardColors.text.muted }}>No agent data available</span>
                <span className="text-sm" style={{ color: dashboardColors.text.light }}>Add agents to see rankings</span>
              </div>
            ) : (
              <Bar data={agentBarChartData} options={{ ...chartOptions, plugins: { ...chartOptions.plugins, legend: { display: false } } }} />
            ),
            delay: "200ms"
          }
        ].map((chart, index) => (
          <div 
            key={index}
            className="group relative overflow-hidden rounded-2xl xs:rounded-3xl transition-all duration-300 hover:scale-[1.02] hover:shadow-2xl animate-slideUp"
            style={{ 
              backgroundColor: dashboardColors.background.white, 
              boxShadow: dashboardColors.shadow.lg,
              animationDelay: chart.delay,
              border: `1px solid ${dashboardColors.border.light}`
            }}
          >
            {/* Chart Header */}
            <div className="p-fluid-2 xs:p-fluid-4 lg:p-fluid-6 border-b" style={{ borderColor: dashboardColors.border.light }}>
              <div className="flex items-center gap-fluid-1 xs:gap-3 mb-fluid-1 xs:mb-2">
                <div className="p-1.5 xs:p-2 rounded-lg group-hover:scale-110 transition-transform duration-200" style={{ backgroundColor: dashboardColors.primary.lightGold + '20' }}>
                  <span style={{ color: dashboardColors.primary.gold }}>{chart.icon}</span>
                </div>
                <div className="min-w-0 flex-1">
                  <h3 className="text-fluid-base xs:text-fluid-lg lg:text-fluid-xl font-bold group-hover:text-opacity-80 transition-colors duration-200 truncate" style={{ color: dashboardColors.text.primary }}>
                    {chart.title}
                  </h3>
                  <p className="text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.secondary }}>{chart.subtitle}</p>
                </div>
              </div>
            </div>
            
            {/* Chart Content */}
            <div className="p-fluid-2 xs:p-fluid-4 lg:p-fluid-6">
              <div className="h-64 xs:h-72 lg:h-80 flex items-center justify-center">
                {chart.component}
              </div>
            </div>
            
            {/* Decorative Elements */}
            <div className="absolute top-0 right-0 w-32 h-32 rounded-full opacity-5 transform translate-x-16 -translate-y-16 group-hover:scale-150 transition-transform duration-500" style={{ backgroundColor: dashboardColors.primary.gold }}></div>
          </div>
        ))}
      </div>

      {/* Enhanced Summary Stats */}
      <div className="grid grid-cols-1 xs:grid-cols-2 lg:grid-cols-4 gap-fluid-2 xs:gap-fluid-4 lg:gap-fluid-6">
        {[
          {
            title: "Total Payments",
            value: totalPayments.toLocaleString(),
            icon: <FaMoneyBillWave className="text-2xl" />,
            gradient: dashboardColors.gradient.primary,
            delay: "0ms"
          },
          {
            title: "Total Amount",
            value: `$${totalAmount.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
            icon: <FaChartLine className="text-2xl" />,
            gradient: `linear-gradient(135deg, ${dashboardColors.status.success} 0%, #38A169 100%)`,
            delay: "100ms"
          },
          {
            title: "Today's Payments",
            value: todaysPaymentsCount.toLocaleString(),
            icon: <FaCalendarAlt className="text-2xl" />,
            gradient: `linear-gradient(135deg, ${dashboardColors.status.info} 0%, #2B6CB0 100%)`,
            delay: "200ms"
          },
          {
            title: "Today's Amount",
            value: `$${todaysAmount.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
            icon: <FaCrown className="text-2xl" />,
            gradient: `linear-gradient(135deg, ${dashboardColors.status.warning} 0%, #D69E2E 100%)`,
            delay: "300ms"
          }
        ].map((stat, index) => (
          <div 
            key={index}
            className="group relative overflow-hidden p-fluid-2 xs:p-fluid-4 lg:p-fluid-6 rounded-xl xs:rounded-2xl transition-all duration-300 hover:scale-105 hover:shadow-2xl animate-slideUp cursor-pointer"
            style={{ 
              background: stat.gradient,
              boxShadow: dashboardColors.shadow.lg,
              animationDelay: stat.delay
            }}
          >
            <div className="relative z-10">
              <div className="flex items-center justify-between mb-fluid-2 xs:mb-4">
                <div className="p-2 xs:p-3 rounded-lg xs:rounded-xl bg-white/20 backdrop-blur-sm group-hover:scale-110 transition-transform duration-200">
                  <span className="text-white text-lg xs:text-xl lg:text-2xl">{stat.icon}</span>
                </div>
                <div className="text-right">
                  <div className="w-6 h-6 xs:w-8 xs:h-8 rounded-full bg-white/10 flex items-center justify-center">
                    <div className="w-1.5 h-1.5 xs:w-2 xs:h-2 rounded-full bg-white animate-pulse"></div>
                  </div>
                </div>
              </div>
              <h3 className="text-white/90 text-fluid-xs xs:text-fluid-sm font-medium mb-1 xs:mb-2 group-hover:text-white transition-colors duration-200">{stat.title}</h3>
              <p className="text-white text-fluid-xl xs:text-fluid-2xl lg:text-fluid-3xl font-bold group-hover:scale-105 transition-transform duration-200 leading-tight">{stat.value}</p>
            </div>
            {/* Decorative Background Elements */}
            <div className="absolute top-0 right-0 w-24 h-24 rounded-full bg-white/5 transform translate-x-8 -translate-y-8 group-hover:scale-150 transition-transform duration-500"></div>
            <div className="absolute bottom-0 left-0 w-16 h-16 rounded-full bg-white/5 transform -translate-x-4 translate-y-4 group-hover:scale-125 transition-transform duration-500"></div>
            {/* Hover Glow Effect */}
            <div className="absolute inset-0 bg-white/0 group-hover:bg-white/5 transition-colors duration-300 rounded-2xl"></div>
          </div>
        ))}
      </div>

      {/* Top Agents Section */}
      <div 
        className="rounded-2xl p-8 transition-all duration-300 hover:shadow-2xl animate-slideUp"
        style={{ 
          backgroundColor: dashboardColors.background.white,
          boxShadow: dashboardColors.shadow.lg,
          animationDelay: '400ms'
        }}
      >
        <div className="flex items-center mb-8">
          <div className="p-3 rounded-xl mr-4" style={{ backgroundColor: dashboardColors.primary.lightGold }}>
            <FaCrown className="text-2xl" style={{ color: dashboardColors.primary.gold }} />
          </div>
          <div>
            <h2 className="text-3xl font-bold" style={{ color: dashboardColors.text.primary }}>Top Performing Agents</h2>
            <p className="text-lg" style={{ color: dashboardColors.text.secondary }}>Our highest collecting agents this period</p>
          </div>
        </div>
        
        {agents.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[...agents]
              .sort((a, b) => (b.totalDonation || 0) - (a.totalDonation || 0))
              .slice(0, 3)
              .map((agent, index) => (
                <div 
                  key={agent._id || agent.id || index} 
                  className="relative p-6 rounded-xl transition-all duration-200 hover:scale-105 group cursor-pointer"
                  style={{ 
                    backgroundColor: index === 0 ? dashboardColors.primary.lightGold : dashboardColors.background.light,
                    border: `1px solid ${dashboardColors.border.light}`,
                    boxShadow: dashboardColors.shadow.md
                  }}
                >
                  {index === 0 && (
                    <FaCrown className="absolute -top-2 -right-2 text-yellow-500 text-xl" />
                  )}
                  <div className="flex items-center mb-4">
                    <div className="relative mr-4">
                      <div 
                        className="w-16 h-16 rounded-full flex items-center justify-center text-white font-bold text-xl overflow-hidden"
                        style={{ 
                          background: index === 0 ? dashboardColors.gradient.primary : dashboardColors.gradient.secondary
                        }}
                      >
                        {agent.profileImage || agent.profileImageUrl || agent.image ? (
                          <img
                            src={agent.profileImage || agent.profileImageUrl || agent.image}
                            alt={agent.fullName}
                            className="w-full h-full object-cover rounded-full"
                          />
                        ) : (
                          agent.fullName ? agent.fullName.charAt(0).toUpperCase() : '?'
                        )}
                      </div>
                      <div 
                        className="absolute -bottom-1 -right-1 w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold text-white"
                        style={{ backgroundColor: dashboardColors.primary.gold }}
                      >
                        #{index + 1}
                      </div>
                    </div>
                    <div className="flex-1">
                      <h4 className="font-semibold text-lg mb-1" style={{ color: dashboardColors.text.primary }}>
                        {agent.fullName}
                      </h4>
                      <p className="text-sm" style={{ color: dashboardColors.text.secondary }}>
                        {agent.email}
                      </p>
                    </div>
                  </div>
                  <div className="text-center p-4 rounded-lg" style={{ backgroundColor: 'rgba(255,255,255,0.5)' }}>
                    <p className="text-2xl font-bold" style={{ color: dashboardColors.primary.gold }}>
                      ${(agent.totalDonation || 0).toLocaleString('en-US', { minimumFractionDigits: 2 })}
                    </p>
                    <p className="text-sm" style={{ color: dashboardColors.text.secondary }}>Total Collected</p>
                  </div>
                </div>
              ))}
          </div>
        ) : (
          <div className="text-center p-8" style={{ color: dashboardColors.text.secondary }}>
            No agents data available
          </div>
        )}
      </div>
    </div>
  );
};

export default Overview;