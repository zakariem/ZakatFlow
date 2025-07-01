import React, { useState, useEffect } from "react";
import axios from "axios";
import {adminApi} from "../api/adminApi";

const filters = ["All", "Today", "This Week", "This Month"];

function PaymentManagement() {
  const [selectedFilter, setSelectedFilter] = useState("All");
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const paymentsResponse = await axios.get(adminApi.getPayments, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('authToken')}`
          }
        });
        let data = paymentsResponse.data;
        if (Array.isArray(data)) {
          setPayments(data);
        } else if (Array.isArray(data.data)) {
          setPayments(data.data);
        } else {
          setPayments([]);
        }
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  // Filtering logic
  const today = new Date();
  const startOfWeek = new Date(today);
  startOfWeek.setDate(today.getDate() - today.getDay());
  startOfWeek.setHours(0, 0, 0, 0);
  const endOfWeek = new Date(startOfWeek);
  endOfWeek.setDate(startOfWeek.getDate() + 6);
  endOfWeek.setHours(23, 59, 59, 999);

  const filteredPayments = payments.filter(payment => {
    const paidAt = payment.paidAt ? new Date(payment.paidAt) : null;
    if (!paidAt) return false;
    if (selectedFilter === "Today") {
      return paidAt.getFullYear() === today.getFullYear() &&
        paidAt.getMonth() === today.getMonth() &&
        paidAt.getDate() === today.getDate();
    } else if (selectedFilter === "This Week") {
      return paidAt >= startOfWeek && paidAt <= endOfWeek;
    } else if (selectedFilter === "This Month") {
      return paidAt.getFullYear() === today.getFullYear() &&
        paidAt.getMonth() === today.getMonth();
    }
    return true; // All
  });

  // Calculate summary values from payments
  const totalPayments = payments.length;
  const totalAmount = payments.reduce((sum, p) => sum + (parseFloat(p.amount) || 0), 0);
  const todaysPayments = payments.filter(p => {
    const paidAt = p.paidAt ? new Date(p.paidAt) : null;
    return paidAt &&
      paidAt.getFullYear() === today.getFullYear() &&
      paidAt.getMonth() === today.getMonth() &&
      paidAt.getDate() === today.getDate();
  }).length;

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error}</p>;

  return (
    <>
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-2xl font-semibold">Payment Management</h1>
        <button className="text-gray-500 hover:text-gray-700">
          <svg
            width="24"
            height="24"
            fill="none"
            viewBox="0 0 24 24"
          >
            <path
              d="M12 4v16m8-8H4"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
            />
          </svg>
        </button>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <div className="flex items-center bg-white rounded-xl shadow-sm p-4">
          <div className="mr-4">💰</div>
          <div>
            <div className="text-lg font-semibold text-green-600">
              {totalAmount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
            </div>
            <div className="text-gray-500 text-sm">Total Amount</div>
          </div>
        </div>
        <div className="flex items-center bg-white rounded-xl shadow-sm p-4">
          <div className="mr-4">🧾</div>
          <div>
            <div className="text-lg font-semibold text-blue-600">
              {totalPayments}
            </div>
            <div className="text-gray-500 text-sm">Total Payments</div>
          </div>
        </div>
        <div className="flex items-center bg-white rounded-xl shadow-sm p-4">
          <div className="mr-4">📅</div>
          <div>
            <div className="text-lg font-semibold text-orange-500">
              {todaysPayments}
            </div>
            <div className="text-gray-500 text-sm">Today's Payments</div>
          </div>
        </div>
      </div>
      <div className="flex items-center mb-4">
        <span className="mr-3 text-gray-600 font-medium">Filter:</span>
        {filters.map((filter) => (
          <button
            key={filter}
            onClick={() => setSelectedFilter(filter)}
            className={`px-4 py-1 rounded-lg mr-2 border transition-colors duration-150 ${
              selectedFilter === filter
                ? "bg-blue-100 border-blue-400 text-blue-700"
                : "bg-white border-gray-300 text-gray-600 hover:bg-gray-100"
            }`}
          >
            {filter}
          </button>
        ))}
      </div>
      <div className="space-y-4">
        {filteredPayments.length === 0 ? (
          <div className="text-center text-gray-500 py-8">No payments found for this filter.</div>
        ) : (
          filteredPayments.map((payment, idx) => (
            <div
              key={payment._id || idx}
              className="bg-white rounded-xl shadow p-6 flex flex-col md:flex-row md:items-center md:justify-between mb-2"
            >
              <div className="flex items-center mb-2 md:mb-0">
                <div className="w-12 h-12 rounded-full bg-green-100 flex items-center justify-center mr-4">
                  <svg
                    width="28"
                    height="28"
                    fill="none"
                    viewBox="0 0 36 36"
                  >
                    <rect width="28" height="28" rx="10" fill="#F5F7FA" />
                    <path
                      d="M10 14A3 3 0 0 1 13 11h10a3 3 0 0 1 3 3v8a3 3 0 0 1-3 3H13a3 3 0 0 1-3-3v-8Z"
                      fill="#2196F3"
                    />
                    <rect
                      x="13"
                      y="17"
                      width="10"
                      height="3"
                      rx="1.5"
                      fill="#90CAF9"
                    />
                  </svg>
                </div>
                <div>
                  <div className="text-lg font-bold">
                    {(payment.currency || '$') + ' ' + (parseFloat(payment.amount).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 }))}
                  </div>
                  <div className="text-gray-500 text-sm">{payment.paidAt ? new Date(payment.paidAt).toLocaleString() : ''}</div>
                </div>
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-x-8 gap-y-2 flex-1">
                <div>
                  <div className="text-xs text-gray-400">Payer</div>
                  <div className="font-semibold">{payment.userFullName}</div>
                </div>
                <div>
                  <div className="text-xs text-gray-400">Agent</div>
                  <div className="font-semibold">{payment.agentName}</div>
                </div>
                <div>
                  <div className="text-xs text-gray-400">Phone</div>
                  <div className="font-semibold">{payment.userAccountNo}</div>
                </div>
                <div>
                  <div className="text-xs text-gray-400">Method</div>
                  <div className="font-semibold">{payment.paymentMethod}</div>
                </div>
                <div>
                  <div className="text-xs text-gray-400">Transaction ID</div>
                  <div className="font-semibold">{payment.waafiResponse && payment.waafiResponse.transactionId}</div>
                </div>
              </div>
              <div className="flex items-center mt-4 md:mt-0">
                <span className="bg-green-100 text-green-700 px-4 py-1 rounded-full text-xs font-semibold">
                  {payment.waafiResponse && payment.waafiResponse.state}
                </span>
              </div>
            </div>
          ))
        )}
      </div>
    </>
  );
}

export default PaymentManagement;