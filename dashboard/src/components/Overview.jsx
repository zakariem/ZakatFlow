import React, { useState, useEffect } from "react";
import axios from "axios";
import { adminApi } from "../api/adminApi";
import { dashboardColors } from "../theme/dashboardColors";
import { FaCrown } from "react-icons/fa";
import { Line, Bar, Doughnut } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
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
  ArcElement,
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
          axios.get(adminApi.getPayments, {
            headers: { 'Authorization': `Bearer ${localStorage.getItem('authToken')}` }
          }),
          axios.get(adminApi.getAgents, {
            headers: { 'Authorization': `Bearer ${localStorage.getItem('authToken')}` }
          })
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

  // Payment status breakdown (doughnut)
  const statusCounts = validPayments.reduce((acc, p) => {
    const status = (p.waafiResponse && p.waafiResponse.state) || p.status || 'Unknown';
    acc[status] = (acc[status] || 0) + 1;
    return acc;
  }, {});
  const statusLabels = Object.keys(statusCounts);
  const statusData = Object.values(statusCounts);
  const statusColors = [
    '#4CAF50', // Approved/Success
    '#FFC107', // Pending
    '#F44336', // Failed
    '#2196F3', // Other
    '#9C27B0',
    '#FF9800',
    '#607D8B',
    '#795548',
    '#00BCD4',
    '#E91E63',
  ];

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

  const doughnutChartData = {
    labels: statusLabels,
    datasets: [
      {
        label: 'Payments by Status',
        data: statusData,
        backgroundColor: statusLabels.map((_, i) => statusColors[i % statusColors.length]),
        borderWidth: 2,
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
    <div className="space-y-8 animate-fadeIn">
      {/* Header */}
      <div className="text-center lg:text-left">
        <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold mb-2 bg-gradient-to-r from-yellow-600 to-yellow-800 bg-clip-text text-transparent">
          Dashboard Overview
        </h1>
        <p className="text-lg" style={{ color: dashboardColors.text.secondary }}>
          Welcome back! Here's what's happening with your Zakat operations today.
        </p>
      </div>

      {/* Enhanced Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Amount Trend Chart */}
        <div className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl" style={{ backgroundColor: dashboardColors.background.white, boxShadow: dashboardColors.shadow.lg }}>
          <h3 className="text-xl font-semibold mb-4" style={{ color: dashboardColors.text.primary }}>Payment Amounts Trend (Last 14 Days)</h3>
          <div className="h-80 flex items-center justify-center">
            {dailyPayments.every(day => day.amount === 0) ? (
              <span className="text-gray-400">No payment data for the last 14 days.</span>
            ) : (
              <Line options={chartOptions} data={amountChartData} />
            )}
          </div>
        </div>
        {/* Payments Count Chart */}
        <div className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl" style={{ backgroundColor: dashboardColors.background.white, boxShadow: dashboardColors.shadow.lg }}>
          <h3 className="text-xl font-semibold mb-4" style={{ color: dashboardColors.text.primary }}>Number of Payments (Last 14 Days)</h3>
          <div className="h-80 flex items-center justify-center">
            {dailyPayments.every(day => day.count === 0) ? (
              <span className="text-gray-400">No payment count data for the last 14 days.</span>
            ) : (
              <Bar options={chartOptions} data={paymentsChartData} />
            )}
          </div>
        </div>
        {/* Payment Status Doughnut Chart */}
        <div className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl" style={{ backgroundColor: dashboardColors.background.white, boxShadow: dashboardColors.shadow.lg }}>
          <h3 className="text-xl font-semibold mb-4" style={{ color: dashboardColors.text.primary }}>Payments by Status</h3>
          <div className="h-80 flex items-center justify-center">
            {statusLabels.length === 0 || statusData.every(v => v === 0) ? (
              <span className="text-gray-400">No payment status data available.</span>
            ) : (
              <Doughnut data={doughnutChartData} options={{ ...chartOptions, cutout: '70%' }} />
            )}
          </div>
        </div>
        {/* Top Agents Bar Chart */}
        <div className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl" style={{ backgroundColor: dashboardColors.background.white, boxShadow: dashboardColors.shadow.lg }}>
          <h3 className="text-xl font-semibold mb-4" style={{ color: dashboardColors.text.primary }}>Top 5 Agents by Collection</h3>
          <div className="h-80 flex items-center justify-center">
            {topAgentLabels.length === 0 || topAgentData.every(v => v === 0) ? (
              <span className="text-gray-400">No agent collection data available.</span>
            ) : (
              <Bar data={agentBarChartData} options={{ ...chartOptions, plugins: { ...chartOptions.plugins, legend: { display: false } } }} />
            )}
          </div>
        </div>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
        <div 
          className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl"
          style={{ 
            background: dashboardColors.gradient.primary,
            boxShadow: dashboardColors.shadow.lg
          }}
        >
          <h3 className="text-white/90 text-sm font-medium mb-2">Total Payments</h3>
          <p className="text-white text-3xl font-bold">{totalPayments.toLocaleString()}</p>
        </div>

        <div 
          className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl"
          style={{ 
            background: dashboardColors.gradient.primary,
            boxShadow: dashboardColors.shadow.lg
          }}
        >
          <h3 className="text-white/90 text-sm font-medium mb-2">Total Amount</h3>
          <p className="text-white text-3xl font-bold">
            ${totalAmount.toLocaleString('en-US', { minimumFractionDigits: 2 })}
          </p>
        </div>

        <div 
          className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl"
          style={{ 
            background: dashboardColors.gradient.primary,
            boxShadow: dashboardColors.shadow.lg
          }}
        >
          <h3 className="text-white/90 text-sm font-medium mb-2">Today's Payments</h3>
          <p className="text-white text-3xl font-bold">{todaysPaymentsCount.toLocaleString()}</p>
        </div>

        <div 
          className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl"
          style={{ 
            background: dashboardColors.gradient.primary,
            boxShadow: dashboardColors.shadow.lg
          }}
        >
          <h3 className="text-white/90 text-sm font-medium mb-2">Today's Amount</h3>
          <p className="text-white text-3xl font-bold">
            ${todaysAmount.toLocaleString('en-US', { minimumFractionDigits: 2 })}
          </p>
        </div>
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