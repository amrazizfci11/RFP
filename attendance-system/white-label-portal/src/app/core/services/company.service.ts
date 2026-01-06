import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '@environments/environment';
import { Company, CompanyFilters, PaginatedResponse } from '../../store/company/company.actions';

@Injectable({
  providedIn: 'root'
})
export class CompanyService {
  private http = inject(HttpClient);
  private baseUrl = `${environment.apiUrl}/admin/companies`;

  getCompanies(filters: CompanyFilters): Observable<PaginatedResponse<Company>> {
    let params = new HttpParams()
      .set('page', filters.page.toString())
      .set('pageSize', filters.pageSize.toString());

    if (filters.search) {
      params = params.set('search', filters.search);
    }
    if (filters.status) {
      params = params.set('status', filters.status);
    }
    if (filters.packageId) {
      params = params.set('packageId', filters.packageId);
    }

    return this.http.get<PaginatedResponse<Company>>(this.baseUrl, { params });
  }

  getCompany(id: string): Observable<Company> {
    return this.http.get<Company>(`${this.baseUrl}/${id}`);
  }

  createCompany(company: Partial<Company>): Observable<Company> {
    return this.http.post<Company>(this.baseUrl, company);
  }

  updateCompany(id: string, company: Partial<Company>): Observable<Company> {
    return this.http.put<Company>(`${this.baseUrl}/${id}`, company);
  }

  deleteCompany(id: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`);
  }

  activateCompany(id: string): Observable<Company> {
    return this.http.post<Company>(`${this.baseUrl}/${id}/activate`, {});
  }

  deactivateCompany(id: string): Observable<Company> {
    return this.http.post<Company>(`${this.baseUrl}/${id}/deactivate`, {});
  }

  uploadLogo(id: string, file: File): Observable<{ logoUrl: string }> {
    const formData = new FormData();
    formData.append('logo', file);
    return this.http.post<{ logoUrl: string }>(`${this.baseUrl}/${id}/logo`, formData);
  }

  getStatistics(): Observable<{
    totalCompanies: number;
    activeCompanies: number;
    expiredSubscriptions: number;
    totalEmployees: number;
    revenueThisMonth: number;
    revenueGrowth: number;
  }> {
    return this.http.get<any>(`${this.baseUrl}/statistics`);
  }
}
