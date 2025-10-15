// Employees Management Implementation
// Add this script to your employees management HTML page

let currentPage = 1;
let currentFilters = {};
let employeesData = [];

document.addEventListener('DOMContentLoaded', function() {
  // Initialize employees page
  initializeEmployeesPage();
  
  // Setup event listeners
  setupEventListeners();
});

// Initialize employees page
async function initializeEmployeesPage() {
  try {
    // Load initial data
    await loadEmployees();
    await loadFilterOptions();
    
  } catch (error) {
    console.error('Error initializing employees page:', error);
    AdminAPI.showError('Error loading employees data: ' + error.message, 'employees-error');
  }
}

// Setup event listeners
function setupEventListeners() {
  // Search input
  const searchInput = document.getElementById('employee-search');
  if (searchInput) {
    searchInput.addEventListener('input', debounce(handleSearch, 300));
  }
  
  // Filter selects
  const departmentFilter = document.getElementById('department-filter');
  const statusFilter = document.getElementById('status-filter');
  const roleFilter = document.getElementById('role-filter');
  
  if (departmentFilter) {
    departmentFilter.addEventListener('change', handleFilterChange);
  }
  if (statusFilter) {
    statusFilter.addEventListener('change', handleFilterChange);
  }
  if (roleFilter) {
    roleFilter.addEventListener('change', handleFilterChange);
  }
  
  // Sort options
  const sortBy = document.getElementById('sort-by');
  const sortOrder = document.getElementById('sort-order');
  
  if (sortBy) {
    sortBy.addEventListener('change', handleSortChange);
  }
  if (sortOrder) {
    sortOrder.addEventListener('change', handleSortChange);
  }
  
  // Items per page
  const itemsPerPage = document.getElementById('items-per-page');
  if (itemsPerPage) {
    itemsPerPage.addEventListener('change', handleItemsPerPageChange);
  }
}

// Load employees data
async function loadEmployees(page = 1) {
  try {
    AdminAPI.showLoading('employees-table');
    
    const params = {
      page: page,
      limit: document.getElementById('items-per-page')?.value || 10,
      ...currentFilters
    };
    
    const response = await AdminAPI.getEmployees(params);
    
    if (response.success) {
      employeesData = response.data.employees;
      populateEmployeesTable(response.data.employees);
      populatePagination(response.data.pagination);
      updateEmployeesSummary(response.data.summary);
      currentPage = page;
    }
    
  } catch (error) {
    console.error('Error loading employees:', error);
    AdminAPI.showError('Error loading employees: ' + error.message, 'employees-table');
  }
}

// Load filter options
async function loadFilterOptions() {
  try {
    const response = await AdminAPI.getEmployees({ limit: 1 });
    
    if (response.success && response.data.filters) {
      populateFilterOptions(response.data.filters);
    }
    
  } catch (error) {
    console.error('Error loading filter options:', error);
  }
}

// Populate filter dropdowns
function populateFilterOptions(filters) {
  // Department filter
  const departmentFilter = document.getElementById('department-filter');
  if (departmentFilter && filters.departments) {
    departmentFilter.innerHTML = '<option value="">Semua Departemen</option>';
    filters.departments.forEach(dept => {
      departmentFilter.innerHTML += `<option value="${dept}">${dept}</option>`;
    });
  }
  
  // Role filter
  const roleFilter = document.getElementById('role-filter');
  if (roleFilter && filters.roles) {
    roleFilter.innerHTML = '<option value="">Semua Role</option>';
    filters.roles.forEach(role => {
      const roleLabel = {
        'employee': 'Karyawan',
        'admin': 'Admin',
        'super_admin': 'Super Admin',
        'account_officer': 'Account Officer',
        'manager': 'Manager'
      }[role] || role;
      roleFilter.innerHTML += `<option value="${role}">${roleLabel}</option>`;
    });
  }
  
  // Status filter
  const statusFilter = document.getElementById('status-filter');
  if (statusFilter && filters.statuses) {
    statusFilter.innerHTML = '<option value="">Semua Status</option>';
    filters.statuses.forEach(status => {
      const statusLabel = {
        'active': 'Aktif',
        'inactive': 'Tidak Aktif',
        'terminated': 'Terminated',
        'resigned': 'Resign'
      }[status] || status;
      statusFilter.innerHTML += `<option value="${status}">${statusLabel}</option>`;
    });
  }
}

// Populate employees table
function populateEmployeesTable(employees) {
  const tableBody = document.getElementById('employees-table-body');
  if (!tableBody) return;
  
  if (employees.length === 0) {
    tableBody.innerHTML = `
      <tr>
        <td colspan="8" class="text-center text-muted py-4">
          <i class="fa fa-users fa-2x mb-2"></i>
          <br>Tidak ada data karyawan
        </td>
      </tr>
    `;
    return;
  }
  
  let tableHtml = '';
  employees.forEach(employee => {
    const statusBadge = AdminAPI.getStatusBadgeClass(employee.status);
    tableHtml += `
      <tr>
        <td>
          <input type="checkbox" class="form-check-input employee-checkbox" 
                 value="${employee.id}" data-employee-id="${employee.id}">
        </td>
        <td>
          <div class="d-flex align-items-center">
            <div class="avatar-sm bg-primary rounded-circle d-flex align-items-center justify-content-center text-white me-2">
              ${employee.full_name?.charAt(0).toUpperCase() || 'U'}
            </div>
            <div>
              <strong>${employee.full_name || '-'}</strong>
              <br><small class="text-muted">${employee.employee_id || '-'}</small>
            </div>
          </div>
        </td>
        <td>${employee.email || '-'}</td>
        <td>${employee.department || '-'}</td>
        <td>${employee.position || '-'}</td>
        <td>
          <span class="badge ${statusBadge}">
            ${getStatusLabel(employee.status)}
          </span>
        </td>
        <td>${AdminAPI.formatDate(employee.hire_date)}</td>
        <td>
          <div class="btn-group btn-group-sm">
            <button class="btn btn-outline-primary btn-sm" onclick="viewEmployee('${employee.id}')" title="View">
              <i class="fa fa-eye"></i>
            </button>
            <button class="btn btn-outline-warning btn-sm" onclick="editEmployee('${employee.id}')" title="Edit">
              <i class="fa fa-edit"></i>
            </button>
            <button class="btn btn-outline-info btn-sm" onclick="resetPassword('${employee.id}')" title="Reset Password">
              <i class="fa fa-key"></i>
            </button>
            <button class="btn btn-outline-danger btn-sm" onclick="confirmDeleteEmployee('${employee.id}')" title="Delete">
              <i class="fa fa-trash"></i>
            </button>
          </div>
        </td>
      </tr>
    `;
  });
  
  tableBody.innerHTML = tableHtml;
}

// Get status label in Indonesian
function getStatusLabel(status) {
  const labels = {
    'active': 'Aktif',
    'inactive': 'Tidak Aktif', 
    'terminated': 'Terminated',
    'resigned': 'Resign'
  };
  return labels[status] || status;
}

// Populate pagination
function populatePagination(pagination) {
  const paginationElement = document.getElementById('pagination');
  if (!paginationElement) return;
  
  let paginationHtml = '';
  
  // Previous button
  if (pagination.has_prev) {
    paginationHtml += `
      <li class="page-item">
        <button class="page-link" onclick="loadEmployees(${pagination.current_page - 1})">Previous</button>
      </li>
    `;
  } else {
    paginationHtml += '<li class="page-item disabled"><span class="page-link">Previous</span></li>';
  }
  
  // Page numbers
  const startPage = Math.max(1, pagination.current_page - 2);
  const endPage = Math.min(pagination.total_pages, pagination.current_page + 2);
  
  for (let i = startPage; i <= endPage; i++) {
    if (i === pagination.current_page) {
      paginationHtml += `<li class="page-item active"><span class="page-link">${i}</span></li>`;
    } else {
      paginationHtml += `<li class="page-item"><button class="page-link" onclick="loadEmployees(${i})">${i}</button></li>`;
    }
  }
  
  // Next button
  if (pagination.has_next) {
    paginationHtml += `
      <li class="page-item">
        <button class="page-link" onclick="loadEmployees(${pagination.current_page + 1})">Next</button>
      </li>
    `;
  } else {
    paginationHtml += '<li class="page-item disabled"><span class="page-link">Next</span></li>';
  }
  
  paginationElement.innerHTML = paginationHtml;
  
  // Update pagination info
  const paginationInfo = document.getElementById('pagination-info');
  if (paginationInfo) {
    const start = ((pagination.current_page - 1) * pagination.per_page) + 1;
    const end = Math.min(start + pagination.per_page - 1, pagination.total_items);
    paginationInfo.textContent = `Showing ${start}-${end} of ${pagination.total_items} employees`;
  }
}

// Update employees summary
function updateEmployeesSummary(summary) {
  const summaryElement = document.getElementById('employees-summary');
  if (summaryElement && summary) {
    summaryElement.innerHTML = `
      <div class="row text-center">
        <div class="col-md-4">
          <h5 class="text-primary">${summary.total}</h5>
          <small class="text-muted">Total Karyawan</small>
        </div>
        <div class="col-md-4">
          <h5 class="text-success">${summary.active}</h5>
          <small class="text-muted">Aktif</small>
        </div>
        <div class="col-md-4">
          <h5 class="text-warning">${summary.inactive}</h5>
          <small class="text-muted">Tidak Aktif</small>
        </div>
      </div>
    `;
  }
}

// Handle search
function handleSearch(event) {
  currentFilters.search = event.target.value;
  loadEmployees(1);
}

// Handle filter change
function handleFilterChange(event) {
  const filterName = event.target.id.replace('-filter', '');
  currentFilters[filterName] = event.target.value;
  loadEmployees(1);
}

// Handle sort change
function handleSortChange(event) {
  const sortBy = document.getElementById('sort-by')?.value;
  const sortOrder = document.getElementById('sort-order')?.value;
  
  if (sortBy) currentFilters.sort_by = sortBy;
  if (sortOrder) currentFilters.sort_order = sortOrder;
  
  loadEmployees(1);
}

// Handle items per page change
function handleItemsPerPageChange(event) {
  loadEmployees(1);
}

// Clear all filters
function clearFilters() {
  currentFilters = {};
  
  // Reset form elements
  document.getElementById('employee-search').value = '';
  document.getElementById('department-filter').value = '';
  document.getElementById('status-filter').value = '';
  document.getElementById('role-filter').value = '';
  document.getElementById('sort-by').value = 'full_name';
  document.getElementById('sort-order').value = 'asc';
  
  loadEmployees(1);
}

// Employee actions
function viewEmployee(employeeId) {
  // Open employee detail modal or redirect
  window.location.href = `employee-detail.html?id=${employeeId}`;
}

function editEmployee(employeeId) {
  // Open employee edit modal or redirect
  window.location.href = `employee-edit.html?id=${employeeId}`;
}

async function resetPassword(employeeId) {
  if (!confirm('Reset password untuk karyawan ini? Password baru akan dikirim via email.')) {
    return;
  }
  
  try {
    const response = await AdminAPI.resetEmployeePassword(employeeId);
    
    if (response.success) {
      AdminAPI.showSuccess('Password berhasil direset');
    }
    
  } catch (error) {
    AdminAPI.showError('Error resetting password: ' + error.message);
  }
}

function confirmDeleteEmployee(employeeId) {
  if (confirm('Yakin ingin menghapus karyawan ini?')) {
    deleteEmployee(employeeId);
  }
}

async function deleteEmployee(employeeId) {
  try {
    // Update status to terminated instead of deleting
    const response = await AdminAPI.updateEmployeeStatus(employeeId, {
      status: 'terminated',
      reason: 'Deleted by admin'
    });
    
    if (response.success) {
      AdminAPI.showSuccess('Karyawan berhasil dihapus');
      loadEmployees(currentPage);
    }
    
  } catch (error) {
    AdminAPI.showError('Error deleting employee: ' + error.message);
  }
}

// Bulk actions
function selectAllEmployees() {
  const checkboxes = document.querySelectorAll('.employee-checkbox');
  const selectAllCheckbox = document.getElementById('select-all-employees');
  
  checkboxes.forEach(checkbox => {
    checkbox.checked = selectAllCheckbox.checked;
  });
  
  updateBulkActionsVisibility();
}

function updateBulkActionsVisibility() {
  const checkedBoxes = document.querySelectorAll('.employee-checkbox:checked');
  const bulkActions = document.getElementById('bulk-actions');
  
  if (bulkActions) {
    if (checkedBoxes.length > 0) {
      bulkActions.style.display = 'block';
      document.getElementById('selected-count').textContent = checkedBoxes.length;
    } else {
      bulkActions.style.display = 'none';
    }
  }
}

// Utility function for debouncing
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// Export functions to global scope
window.EmployeesApp = {
  loadEmployees,
  clearFilters,
  viewEmployee,
  editEmployee,
  resetPassword,
  confirmDeleteEmployee,
  selectAllEmployees,
  updateBulkActionsVisibility
};