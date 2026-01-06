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
import { Store } from '@ngrx/store';
import { TranslateModule } from '@ngx-translate/core';

import { CompanyActions, CompanyFilters } from '../../../store/company/company.actions';
import {
  selectCompanies,
  selectCompanyLoading,
  selectCompanyTotalCount,
  selectCompanyFilters
} from '../../../store/company/company.selectors';

@Component({
  selector: 'app-company-list',
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
    TranslateModule
  ],
  template: `
    <div class="company-list-container">
      <div class="header">
        <h1>{{ 'companies.title' | translate }}</h1>
        <button mat-raised-button color="primary" routerLink="create">
          <mat-icon>add</mat-icon>
          {{ 'companies.create' | translate }}
        </button>
      </div>

      <mat-card class="filters-card">
        <mat-card-content>
          <div class="filters">
            <mat-form-field appearance="outline">
              <mat-label>{{ 'common.search' | translate }}</mat-label>
              <input matInput [(ngModel)]="searchTerm" (keyup.enter)="applyFilters()" />
              <mat-icon matSuffix>search</mat-icon>
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>{{ 'companies.status' | translate }}</mat-label>
              <mat-select [(ngModel)]="statusFilter" (selectionChange)="applyFilters()">
                <mat-option value="">{{ 'common.all' | translate }}</mat-option>
                <mat-option value="Active">{{ 'status.active' | translate }}</mat-option>
                <mat-option value="Expired">{{ 'status.expired' | translate }}</mat-option>
                <mat-option value="Trial">{{ 'status.trial' | translate }}</mat-option>
                <mat-option value="Cancelled">{{ 'status.cancelled' | translate }}</mat-option>
              </mat-select>
            </mat-form-field>

            <button mat-stroked-button (click)="resetFilters()">
              <mat-icon>refresh</mat-icon>
              {{ 'common.reset' | translate }}
            </button>
          </div>
        </mat-card-content>
      </mat-card>

      <mat-card class="table-card">
        <mat-card-content>
          @if (loading$ | async) {
            <div class="loading-container">
              <mat-spinner></mat-spinner>
            </div>
          }

          <table mat-table [dataSource]="companies$ | async">
            <ng-container matColumnDef="name">
              <th mat-header-cell *matHeaderCellDef>{{ 'company.name' | translate }}</th>
              <td mat-cell *matCellDef="let company">
                <div class="company-name">
                  @if (company.logoUrl) {
                    <img [src]="company.logoUrl" alt="Logo" class="company-logo" />
                  }
                  <span>{{ company.name }}</span>
                </div>
              </td>
            </ng-container>

            <ng-container matColumnDef="email">
              <th mat-header-cell *matHeaderCellDef>{{ 'company.email' | translate }}</th>
              <td mat-cell *matCellDef="let company">{{ company.email }}</td>
            </ng-container>

            <ng-container matColumnDef="package">
              <th mat-header-cell *matHeaderCellDef>{{ 'company.package' | translate }}</th>
              <td mat-cell *matCellDef="let company">{{ company.subscriptionPackageName }}</td>
            </ng-container>

            <ng-container matColumnDef="status">
              <th mat-header-cell *matHeaderCellDef>{{ 'company.status' | translate }}</th>
              <td mat-cell *matCellDef="let company">
                <span class="status-badge" [class]="company.subscriptionStatus.toLowerCase()">
                  {{ company.subscriptionStatus }}
                </span>
              </td>
            </ng-container>

            <ng-container matColumnDef="employees">
              <th mat-header-cell *matHeaderCellDef>{{ 'company.employees' | translate }}</th>
              <td mat-cell *matCellDef="let company">
                {{ company.employeeCount }} / {{ company.maxEmployees }}
              </td>
            </ng-container>

            <ng-container matColumnDef="actions">
              <th mat-header-cell *matHeaderCellDef></th>
              <td mat-cell *matCellDef="let company">
                <button mat-icon-button [matMenuTriggerFor]="menu">
                  <mat-icon>more_vert</mat-icon>
                </button>
                <mat-menu #menu="matMenu">
                  <a mat-menu-item [routerLink]="[company.id]">
                    <mat-icon>visibility</mat-icon>
                    <span>{{ 'common.view' | translate }}</span>
                  </a>
                  <a mat-menu-item [routerLink]="[company.id, 'edit']">
                    <mat-icon>edit</mat-icon>
                    <span>{{ 'common.edit' | translate }}</span>
                  </a>
                  @if (company.isActive) {
                    <button mat-menu-item (click)="deactivate(company.id)">
                      <mat-icon>block</mat-icon>
                      <span>{{ 'common.deactivate' | translate }}</span>
                    </button>
                  } @else {
                    <button mat-menu-item (click)="activate(company.id)">
                      <mat-icon>check_circle</mat-icon>
                      <span>{{ 'common.activate' | translate }}</span>
                    </button>
                  }
                  <button mat-menu-item (click)="delete(company.id)" class="delete-action">
                    <mat-icon>delete</mat-icon>
                    <span>{{ 'common.delete' | translate }}</span>
                  </button>
                </mat-menu>
              </td>
            </ng-container>

            <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
            <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
          </table>

          <mat-paginator
            [length]="totalCount$ | async"
            [pageSize]="pageSize"
            [pageSizeOptions]="[10, 25, 50]"
            (page)="onPageChange($event)">
          </mat-paginator>
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: [`
    .company-list-container {
      .header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;

        h1 { margin: 0; }
      }

      .filters-card {
        margin-bottom: 24px;

        .filters {
          display: flex;
          gap: 16px;
          align-items: center;

          mat-form-field {
            flex: 1;
            max-width: 300px;
          }
        }
      }

      .loading-container {
        display: flex;
        justify-content: center;
        padding: 48px;
      }

      .company-name {
        display: flex;
        align-items: center;
        gap: 12px;

        .company-logo {
          width: 32px;
          height: 32px;
          border-radius: 4px;
          object-fit: cover;
        }
      }

      .status-badge {
        padding: 4px 12px;
        border-radius: 16px;
        font-size: 12px;
        font-weight: 500;

        &.active {
          background: #e8f5e9;
          color: #2e7d32;
        }

        &.expired {
          background: #ffebee;
          color: #c62828;
        }

        &.trial {
          background: #fff3e0;
          color: #ef6c00;
        }

        &.cancelled {
          background: #fafafa;
          color: #616161;
        }
      }

      .delete-action {
        color: #c62828;
      }

      table {
        width: 100%;
      }
    }
  `]
})
export class CompanyListComponent implements OnInit {
  private store = inject(Store);

  displayedColumns = ['name', 'email', 'package', 'status', 'employees', 'actions'];

  companies$ = this.store.select(selectCompanies);
  loading$ = this.store.select(selectCompanyLoading);
  totalCount$ = this.store.select(selectCompanyTotalCount);
  filters$ = this.store.select(selectCompanyFilters);

  searchTerm = '';
  statusFilter = '';
  pageSize = 10;
  page = 1;

  ngOnInit(): void {
    this.loadCompanies();
  }

  loadCompanies(): void {
    const filters: CompanyFilters = {
      search: this.searchTerm,
      status: this.statusFilter,
      page: this.page,
      pageSize: this.pageSize
    };
    this.store.dispatch(CompanyActions.loadCompanies({ filters }));
  }

  applyFilters(): void {
    this.page = 1;
    this.loadCompanies();
  }

  resetFilters(): void {
    this.searchTerm = '';
    this.statusFilter = '';
    this.page = 1;
    this.loadCompanies();
  }

  onPageChange(event: PageEvent): void {
    this.page = event.pageIndex + 1;
    this.pageSize = event.pageSize;
    this.loadCompanies();
  }

  activate(id: string): void {
    this.store.dispatch(CompanyActions.activateCompany({ id }));
  }

  deactivate(id: string): void {
    this.store.dispatch(CompanyActions.deactivateCompany({ id }));
  }

  delete(id: string): void {
    if (confirm('Are you sure you want to delete this company?')) {
      this.store.dispatch(CompanyActions.deleteCompany({ id }));
    }
  }
}
