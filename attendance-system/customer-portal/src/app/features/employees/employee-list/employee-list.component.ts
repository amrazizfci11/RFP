import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { MatMenuModule } from '@angular/material/menu';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatChipsModule } from '@angular/material/chips';
import { MatTooltipModule } from '@angular/material/tooltip';
import { Store } from '@ngrx/store';
import { TranslateModule } from '@ngx-translate/core';

import { EmployeeService } from '../../../core/services/employee.service';

interface Employee {
  id: string;
  employeeNumber: string;
  name: string;
  nameAr?: string;
  email: string;
  mobile: string;
  iqamaNumber?: string;
  department?: string;
  position?: string;
  isActive: boolean;
  annualVacationDays: number;
  usedVacationDays: number;
  createdAt: string;
}

@Component({
  selector: 'app-employee-list',
  standalone: true,
  imports: [
    CommonModule,
    RouterLink,
    FormsModule,
    MatCardModule,
    MatTableModule,
    MatPaginatorModule,
    MatButtonModule,
    MatIconModule,
    MatInputModule,
    MatFormFieldModule,
    MatSelectModule,
    MatMenuModule,
    MatProgressSpinnerModule,
    MatChipsModule,
    MatTooltipModule,
    TranslateModule
  ],
  template: `
    <div class="employee-list-container">
      <div class="header">
        <h1>{{ 'employees.title' | translate }}</h1>
        <div class="header-actions">
          <button mat-stroked-button routerLink="import">
            <mat-icon>upload_file</mat-icon>
            {{ 'employees.import' | translate }}
          </button>
          <button mat-raised-button color="primary" routerLink="create">
            <mat-icon>add</mat-icon>
            {{ 'employees.create' | translate }}
          </button>
        </div>
      </div>

      <mat-card class="filters-card">
        <mat-card-content>
          <div class="filters">
            <mat-form-field appearance="outline">
              <mat-label>{{ 'common.search' | translate }}</mat-label>
              <input matInput [(ngModel)]="searchTerm" (keyup.enter)="applyFilters()"
                     placeholder="Name, email, employee number..." />
              <mat-icon matSuffix>search</mat-icon>
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>{{ 'employees.department' | translate }}</mat-label>
              <mat-select [(ngModel)]="departmentFilter" (selectionChange)="applyFilters()">
                <mat-option value="">{{ 'common.all' | translate }}</mat-option>
                @for (dept of departments; track dept) {
                  <mat-option [value]="dept">{{ dept }}</mat-option>
                }
              </mat-select>
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>{{ 'employees.status' | translate }}</mat-label>
              <mat-select [(ngModel)]="statusFilter" (selectionChange)="applyFilters()">
                <mat-option value="">{{ 'common.all' | translate }}</mat-option>
                <mat-option value="active">{{ 'status.active' | translate }}</mat-option>
                <mat-option value="inactive">{{ 'status.inactive' | translate }}</mat-option>
              </mat-select>
            </mat-form-field>

            <button mat-stroked-button (click)="resetFilters()">
              <mat-icon>refresh</mat-icon>
              {{ 'common.reset' | translate }}
            </button>

            <button mat-stroked-button (click)="exportToExcel()">
              <mat-icon>download</mat-icon>
              {{ 'common.export' | translate }}
            </button>
          </div>
        </mat-card-content>
      </mat-card>

      <mat-card class="table-card">
        <mat-card-content>
          @if (loading) {
            <div class="loading-container">
              <mat-spinner></mat-spinner>
            </div>
          }

          <table mat-table [dataSource]="employees">
            <ng-container matColumnDef="employeeNumber">
              <th mat-header-cell *matHeaderCellDef>{{ 'employees.employeeNumber' | translate }}</th>
              <td mat-cell *matCellDef="let employee">{{ employee.employeeNumber }}</td>
            </ng-container>

            <ng-container matColumnDef="name">
              <th mat-header-cell *matHeaderCellDef>{{ 'employees.name' | translate }}</th>
              <td mat-cell *matCellDef="let employee">
                <div class="employee-name">
                  <span>{{ employee.name }}</span>
                  @if (employee.nameAr) {
                    <small class="name-ar">{{ employee.nameAr }}</small>
                  }
                </div>
              </td>
            </ng-container>

            <ng-container matColumnDef="email">
              <th mat-header-cell *matHeaderCellDef>{{ 'employees.email' | translate }}</th>
              <td mat-cell *matCellDef="let employee">{{ employee.email }}</td>
            </ng-container>

            <ng-container matColumnDef="mobile">
              <th mat-header-cell *matHeaderCellDef>{{ 'employees.mobile' | translate }}</th>
              <td mat-cell *matCellDef="let employee">{{ employee.mobile }}</td>
            </ng-container>

            <ng-container matColumnDef="department">
              <th mat-header-cell *matHeaderCellDef>{{ 'employees.department' | translate }}</th>
              <td mat-cell *matCellDef="let employee">{{ employee.department || '-' }}</td>
            </ng-container>

            <ng-container matColumnDef="vacationBalance">
              <th mat-header-cell *matHeaderCellDef>{{ 'employees.vacationBalance' | translate }}</th>
              <td mat-cell *matCellDef="let employee">
                <span class="vacation-balance"
                      [class.low]="(employee.annualVacationDays - employee.usedVacationDays) < 5">
                  {{ employee.annualVacationDays - employee.usedVacationDays }} / {{ employee.annualVacationDays }}
                </span>
              </td>
            </ng-container>

            <ng-container matColumnDef="status">
              <th mat-header-cell *matHeaderCellDef>{{ 'employees.status' | translate }}</th>
              <td mat-cell *matCellDef="let employee">
                <mat-chip [class]="employee.isActive ? 'active' : 'inactive'">
                  {{ employee.isActive ? ('status.active' | translate) : ('status.inactive' | translate) }}
                </mat-chip>
              </td>
            </ng-container>

            <ng-container matColumnDef="actions">
              <th mat-header-cell *matHeaderCellDef></th>
              <td mat-cell *matCellDef="let employee">
                <button mat-icon-button [matMenuTriggerFor]="menu">
                  <mat-icon>more_vert</mat-icon>
                </button>
                <mat-menu #menu="matMenu">
                  <a mat-menu-item [routerLink]="[employee.id]">
                    <mat-icon>visibility</mat-icon>
                    <span>{{ 'common.view' | translate }}</span>
                  </a>
                  <a mat-menu-item [routerLink]="[employee.id, 'edit']">
                    <mat-icon>edit</mat-icon>
                    <span>{{ 'common.edit' | translate }}</span>
                  </a>
                  <button mat-menu-item (click)="sendMessage(employee)">
                    <mat-icon>message</mat-icon>
                    <span>{{ 'employees.sendMessage' | translate }}</span>
                  </button>
                  <button mat-menu-item (click)="requestClarification(employee)">
                    <mat-icon>help_outline</mat-icon>
                    <span>{{ 'employees.requestClarification' | translate }}</span>
                  </button>
                  @if (employee.isActive) {
                    <button mat-menu-item (click)="deactivate(employee.id)">
                      <mat-icon>block</mat-icon>
                      <span>{{ 'common.deactivate' | translate }}</span>
                    </button>
                  } @else {
                    <button mat-menu-item (click)="activate(employee.id)">
                      <mat-icon>check_circle</mat-icon>
                      <span>{{ 'common.activate' | translate }}</span>
                    </button>
                  }
                </mat-menu>
              </td>
            </ng-container>

            <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
            <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
          </table>

          <mat-paginator
            [length]="totalCount"
            [pageSize]="pageSize"
            [pageSizeOptions]="[10, 25, 50, 100]"
            (page)="onPageChange($event)">
          </mat-paginator>
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: [`
    .employee-list-container {
      .header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;

        h1 { margin: 0; }

        .header-actions {
          display: flex;
          gap: 12px;
        }
      }

      .filters-card {
        margin-bottom: 24px;

        .filters {
          display: flex;
          gap: 16px;
          align-items: center;
          flex-wrap: wrap;

          mat-form-field {
            flex: 1;
            min-width: 200px;
            max-width: 300px;
          }
        }
      }

      .loading-container {
        display: flex;
        justify-content: center;
        padding: 48px;
      }

      .employee-name {
        display: flex;
        flex-direction: column;

        .name-ar {
          color: #666;
          font-size: 12px;
        }
      }

      .vacation-balance {
        &.low {
          color: #c62828;
          font-weight: 500;
        }
      }

      mat-chip {
        &.active {
          background: #e8f5e9 !important;
          color: #2e7d32 !important;
        }

        &.inactive {
          background: #ffebee !important;
          color: #c62828 !important;
        }
      }

      table {
        width: 100%;
      }
    }
  `]
})
export class EmployeeListComponent implements OnInit {
  private employeeService = inject(EmployeeService);

  displayedColumns = ['employeeNumber', 'name', 'email', 'mobile', 'department', 'vacationBalance', 'status', 'actions'];

  employees: Employee[] = [];
  departments: string[] = ['HR', 'IT', 'Finance', 'Operations', 'Sales', 'Marketing'];
  totalCount = 0;
  loading = false;

  searchTerm = '';
  departmentFilter = '';
  statusFilter = '';
  pageSize = 10;
  page = 1;

  ngOnInit(): void {
    this.loadEmployees();
  }

  loadEmployees(): void {
    this.loading = true;
    this.employeeService.getEmployees({
      search: this.searchTerm,
      department: this.departmentFilter,
      status: this.statusFilter,
      page: this.page,
      pageSize: this.pageSize
    }).subscribe({
      next: (response) => {
        this.employees = response.items;
        this.totalCount = response.totalCount;
        this.loading = false;
      },
      error: () => {
        this.loading = false;
      }
    });
  }

  applyFilters(): void {
    this.page = 1;
    this.loadEmployees();
  }

  resetFilters(): void {
    this.searchTerm = '';
    this.departmentFilter = '';
    this.statusFilter = '';
    this.page = 1;
    this.loadEmployees();
  }

  onPageChange(event: PageEvent): void {
    this.page = event.pageIndex + 1;
    this.pageSize = event.pageSize;
    this.loadEmployees();
  }

  activate(id: string): void {
    this.employeeService.activateEmployee(id).subscribe(() => {
      this.loadEmployees();
    });
  }

  deactivate(id: string): void {
    this.employeeService.deactivateEmployee(id).subscribe(() => {
      this.loadEmployees();
    });
  }

  sendMessage(employee: Employee): void {
    // Open message dialog
    console.log('Send message to:', employee);
  }

  requestClarification(employee: Employee): void {
    // Open clarification dialog
    console.log('Request clarification from:', employee);
  }

  exportToExcel(): void {
    this.employeeService.exportToExcel({
      search: this.searchTerm,
      department: this.departmentFilter,
      status: this.statusFilter
    }).subscribe((blob) => {
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `employees_${new Date().toISOString().split('T')[0]}.xlsx`;
      a.click();
      window.URL.revokeObjectURL(url);
    });
  }
}
