import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface Employee {
  id: string;
  employeeNumber: string;
  name: string;
  nameAr?: string;
  email: string;
  mobile: string;
  iqamaNumber?: string;
  nationalId?: string;
  department?: string;
  position?: string;
  isActive: boolean;
  annualVacationDays: number;
  usedVacationDays: number;
  hireDate?: string;
  createdAt: string;
}

export interface EmployeeFilters {
  search?: string;
  department?: string;
  status?: string;
  page: number;
  pageSize: number;
}

export interface PaginatedResponse<T> {
  items: T[];
  totalCount: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface ImportResult {
  totalRows: number;
  successCount: number;
  errorCount: number;
  errors: { row: number; message: string }[];
}

@Injectable({
  providedIn: 'root'
})
export class EmployeeService {
  private http = inject(HttpClient);
  private baseUrl = `${environment.apiUrl}/company/employees`;

  getEmployees(filters: EmployeeFilters): Observable<PaginatedResponse<Employee>> {
    let params = new HttpParams()
      .set('page', filters.page.toString())
      .set('pageSize', filters.pageSize.toString());

    if (filters.search) {
      params = params.set('search', filters.search);
    }
    if (filters.department) {
      params = params.set('department', filters.department);
    }
    if (filters.status) {
      params = params.set('status', filters.status);
    }

    return this.http.get<PaginatedResponse<Employee>>(this.baseUrl, { params });
  }

  getEmployee(id: string): Observable<Employee> {
    return this.http.get<Employee>(`${this.baseUrl}/${id}`);
  }

  createEmployee(employee: Partial<Employee>): Observable<Employee> {
    return this.http.post<Employee>(this.baseUrl, employee);
  }

  updateEmployee(id: string, employee: Partial<Employee>): Observable<Employee> {
    return this.http.put<Employee>(`${this.baseUrl}/${id}`, employee);
  }

  deleteEmployee(id: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`);
  }

  activateEmployee(id: string): Observable<Employee> {
    return this.http.post<Employee>(`${this.baseUrl}/${id}/activate`, {});
  }

  deactivateEmployee(id: string): Observable<Employee> {
    return this.http.post<Employee>(`${this.baseUrl}/${id}/deactivate`, {});
  }

  importFromExcel(file: File): Observable<ImportResult> {
    const formData = new FormData();
    formData.append('file', file);
    return this.http.post<ImportResult>(`${this.baseUrl}/import`, formData);
  }

  exportToExcel(filters: Partial<EmployeeFilters>): Observable<Blob> {
    let params = new HttpParams();
    if (filters.search) {
      params = params.set('search', filters.search);
    }
    if (filters.department) {
      params = params.set('department', filters.department);
    }
    if (filters.status) {
      params = params.set('status', filters.status);
    }

    return this.http.get(`${this.baseUrl}/export`, {
      params,
      responseType: 'blob'
    });
  }

  downloadTemplate(): Observable<Blob> {
    return this.http.get(`${this.baseUrl}/template`, {
      responseType: 'blob'
    });
  }

  getStatistics(): Observable<{
    totalEmployees: number;
    activeEmployees: number;
    inactiveEmployees: number;
    byDepartment: { department: string; count: number }[];
  }> {
    return this.http.get<any>(`${this.baseUrl}/statistics`);
  }

  bulkUpdateDepartment(employeeIds: string[], department: string): Observable<void> {
    return this.http.post<void>(`${this.baseUrl}/bulk/department`, {
      employeeIds,
      department
    });
  }

  bulkUpdateVacationDays(employeeIds: string[], days: number): Observable<void> {
    return this.http.post<void>(`${this.baseUrl}/bulk/vacation-days`, {
      employeeIds,
      days
    });
  }
}
