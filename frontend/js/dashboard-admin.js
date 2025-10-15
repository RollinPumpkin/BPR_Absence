// Dashboard Admin Implementation
// Add this script to your admin dashboard HTML page

document.addEventListener('DOMContentLoaded', function() {
  // Check admin access first
  if (!AdminAPI.initializeAdminPage()) {
    return; // Access denied, user redirected
  }
  
  // Initialize dashboard when page loads
  initializeDashboard();
});

// Main dashboard initialization
async function initializeDashboard() {
  try {
    // Show loading states
    showDashboardLoading();
    
    // Fetch dashboard data
    const dashboardData = await AdminAPI.getDashboardSummary();
    
    if (dashboardData.success) {
      populateDashboardCards(dashboardData.data);
      populateUserStats(dashboardData.data.users);
      populateAttendanceStats(dashboardData.data.attendance_today);
      populateLetterStats(dashboardData.data.letters);
      populateAssignmentStats(dashboardData.data.assignments);
      populateDepartmentChart(dashboardData.data.departments);
      populateRecentHires(dashboardData.data.recent_hires_list);
    }
    
  } catch (error) {
    console.error('Error loading dashboard:', error);
    showDashboardError(error.message);
  }
}

// Show loading states for all dashboard components
function showDashboardLoading() {
  // Update main stats cards
  const statsCards = document.querySelectorAll('.stat-card .card-body');
  statsCards.forEach(card => {
    card.innerHTML = '<div class="text-center"><i class="fa fa-spinner fa-spin"></i></div>';
  });
  
  // Update charts
  const charts = document.querySelectorAll('.chart-container');
  charts.forEach(chart => {
    chart.innerHTML = '<div class="text-center p-3"><i class="fa fa-spinner fa-spin"></i> Loading...</div>';
  });
}

// Populate main dashboard cards
function populateDashboardCards(data) {
  // Total Employees Card
  updateCard('total-employees', data.users.total_employees, 'Total Karyawan');
  
  // Active Employees Card  
  updateCard('active-employees', data.users.active, 'Karyawan Aktif');
  
  // Today Attendance Card
  const attendanceRate = data.users.total_employees > 0 ? 
    Math.round((data.attendance_today.total_marked / data.users.total_employees) * 100) : 0;
  updateCard('attendance-rate', `${attendanceRate}%`, 'Kehadiran Hari Ini');
  
  // Pending Letters Card
  updateCard('pending-letters', data.letters.pending_approval, 'Surat Pending');
  
  // Active Assignments Card
  updateCard('active-assignments', data.assignments.in_progress, 'Tugas Aktif');
}

// Update individual card
function updateCard(cardId, value, title) {
  const cardElement = document.getElementById(cardId);
  if (cardElement) {
    cardElement.innerHTML = `
      <div class="card-body text-center">
        <h3 class="card-title text-primary">${value}</h3>
        <p class="card-text text-muted">${title}</p>
      </div>
    `;
  }
}

// Populate user statistics
function populateUserStats(userStats) {
  const userStatsElement = document.getElementById('user-statistics');
  if (userStatsElement) {
    userStatsElement.innerHTML = `
      <div class="row">
        <div class="col-md-3">
          <div class="stat-item">
            <span class="stat-value text-success">${userStats.active}</span>
            <span class="stat-label">Aktif</span>
          </div>
        </div>
        <div class="col-md-3">
          <div class="stat-item">
            <span class="stat-value text-warning">${userStats.inactive}</span>
            <span class="stat-label">Tidak Aktif</span>
          </div>
        </div>
        <div class="col-md-3">
          <div class="stat-item">
            <span class="stat-value text-danger">${userStats.terminated}</span>
            <span class="stat-label">Terminated</span>
          </div>
        </div>
        <div class="col-md-3">
          <div class="stat-item">
            <span class="stat-value text-secondary">${userStats.resigned}</span>
            <span class="stat-label">Resign</span>
          </div>
        </div>
      </div>
    `;
  }
}

// Populate attendance statistics
function populateAttendanceStats(attendanceData) {
  const attendanceElement = document.getElementById('attendance-statistics');
  if (attendanceElement) {
    attendanceElement.innerHTML = `
      <div class="row text-center">
        <div class="col-md-3">
          <div class="attendance-stat">
            <i class="fa fa-check-circle text-success fa-2x"></i>
            <h4>${attendanceData.present}</h4>
            <p>Hadir</p>
          </div>
        </div>
        <div class="col-md-3">
          <div class="attendance-stat">
            <i class="fa fa-times-circle text-danger fa-2x"></i>
            <h4>${attendanceData.absent}</h4>
            <p>Tidak Hadir</p>
          </div>
        </div>
        <div class="col-md-3">
          <div class="attendance-stat">
            <i class="fa fa-clock text-warning fa-2x"></i>
            <h4>${attendanceData.late}</h4>
            <p>Terlambat</p>
          </div>
        </div>
        <div class="col-md-3">
          <div class="attendance-stat">
            <i class="fa fa-plus-square text-info fa-2x"></i>
            <h4>${attendanceData.sick}</h4>
            <p>Sakit</p>
          </div>
        </div>
      </div>
    `;
  }
}

// Populate letter statistics
function populateLetterStats(letterData) {
  const letterElement = document.getElementById('letter-statistics');
  if (letterElement) {
    letterElement.innerHTML = `
      <div class="row">
        <div class="col-md-6">
          <div class="progress mb-2">
            <div class="progress-bar bg-success" style="width: ${(letterData.approved/letterData.total_letters*100)||0}%"></div>
          </div>
          <small>Disetujui: ${letterData.approved}</small>
        </div>
        <div class="col-md-6">
          <div class="progress mb-2">
            <div class="progress-bar bg-warning" style="width: ${(letterData.pending_approval/letterData.total_letters*100)||0}%"></div>
          </div>
          <small>Pending: ${letterData.pending_approval}</small>
        </div>
      </div>
      <div class="mt-3">
        <p><strong>Total Surat:</strong> ${letterData.total_letters}</p>
        <p><strong>Ditolak:</strong> ${letterData.rejected}</p>
      </div>
    `;
  }
}

// Populate assignment statistics
function populateAssignmentStats(assignmentData) {
  const assignmentElement = document.getElementById('assignment-statistics');
  if (assignmentElement) {
    const completionRate = assignmentData.total_assignments > 0 ? 
      Math.round((assignmentData.completed / assignmentData.total_assignments) * 100) : 0;
      
    assignmentElement.innerHTML = `
      <div class="mb-3">
        <div class="d-flex justify-content-between">
          <span>Tingkat Penyelesaian</span>
          <span><strong>${completionRate}%</strong></span>
        </div>
        <div class="progress">
          <div class="progress-bar bg-primary" style="width: ${completionRate}%"></div>
        </div>
      </div>
      <div class="row text-center">
        <div class="col-4">
          <small class="text-muted">Selesai</small>
          <h5 class="text-success">${assignmentData.completed}</h5>
        </div>
        <div class="col-4">
          <small class="text-muted">Progress</small>
          <h5 class="text-primary">${assignmentData.in_progress}</h5>
        </div>
        <div class="col-4">
          <small class="text-muted">Overdue</small>
          <h5 class="text-danger">${assignmentData.overdue}</h5>
        </div>
      </div>
    `;
  }
}

// Populate department chart (simple horizontal bars)
function populateDepartmentChart(departments) {
  const chartElement = document.getElementById('department-chart');
  if (chartElement && departments.length > 0) {
    const maxCount = Math.max(...departments.map(d => d.count));
    
    let chartHtml = '<div class="department-chart">';
    departments.forEach(dept => {
      const percentage = (dept.count / maxCount) * 100;
      chartHtml += `
        <div class="dept-bar mb-2">
          <div class="d-flex justify-content-between">
            <span class="dept-name">${dept.name}</span>
            <span class="dept-count">${dept.count}</span>
          </div>
          <div class="progress" style="height: 8px;">
            <div class="progress-bar bg-info" style="width: ${percentage}%"></div>
          </div>
        </div>
      `;
    });
    chartHtml += '</div>';
    
    chartElement.innerHTML = chartHtml;
  }
}

// Populate recent hires list
function populateRecentHires(recentHires) {
  const hiresElement = document.getElementById('recent-hires');
  if (hiresElement) {
    if (recentHires.length === 0) {
      hiresElement.innerHTML = '<p class="text-muted text-center">Tidak ada karyawan baru</p>';
      return;
    }
    
    let hiresHtml = '<ul class="list-unstyled">';
    recentHires.forEach(hire => {
      hiresHtml += `
        <li class="d-flex justify-content-between align-items-center mb-2">
          <div>
            <strong>${hire.full_name}</strong>
            <br><small class="text-muted">${hire.department}</small>
          </div>
          <small class="text-info">${AdminAPI.formatDate(hire.hire_date)}</small>
        </li>
      `;
    });
    hiresHtml += '</ul>';
    
    hiresElement.innerHTML = hiresHtml;
  }
}

// Show dashboard error
function showDashboardError(message) {
  const errorElement = document.getElementById('dashboard-error');
  if (errorElement) {
    errorElement.innerHTML = `
      <div class="alert alert-danger">
        <i class="fa fa-exclamation-triangle"></i> 
        Error loading dashboard: ${message}
        <button class="btn btn-sm btn-outline-danger ms-2" onclick="initializeDashboard()">
          <i class="fa fa-refresh"></i> Retry
        </button>
      </div>
    `;
  }
}

// Refresh dashboard data
function refreshDashboard() {
  initializeDashboard();
}

// Quick actions
async function quickCreateEmployee() {
  // This would open a modal or redirect to employee creation page
  window.location.href = 'employees.html?action=create';
}

async function quickViewAttendance() {
  // This would redirect to attendance page  
  window.location.href = 'attendance.html';
}

async function quickViewLetters() {
  // This would redirect to letters page
  window.location.href = 'letters.html';
}

async function quickViewAssignments() {
  // This would redirect to assignments page
  window.location.href = 'assignments.html';
}

// Export functions to global scope for use in HTML
window.DashboardApp = {
  initializeDashboard,
  refreshDashboard,
  quickCreateEmployee,
  quickViewAttendance,
  quickViewLetters,
  quickViewAssignments
};