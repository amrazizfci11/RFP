import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { RouterLink } from '@angular/router';
import { BaseChartDirective } from 'ng2-charts';
import { ChartConfiguration, ChartType } from 'chart.js';
import { TranslateModule } from '@ngx-translate/core';

import { CompanyService } from '../../core/services/company.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    MatCardModule,
    MatIconModule,
    MatTableModule,
    MatButtonModule,
    RouterLink,
    BaseChartDirective,
    TranslateModule
  ],
  template: `
    <div class="dashboard-container">
      <h1>{{ 'dashboard.title' | translate }}</h1>

      <div class="stats-grid">
        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-icon companies">
              <mat-icon>business</mat-icon>
            </div>
            <div class="stat-info">
              <h3>{{ stats.totalCompanies }}</h3>
              <p>{{ 'dashboard.totalCompanies' | translate }}</p>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-icon active">
              <mat-icon>check_circle</mat-icon>
            </div>
            <div class="stat-info">
              <h3>{{ stats.activeCompanies }}</h3>
              <p>{{ 'dashboard.activeCompanies' | translate }}</p>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-icon warning">
              <mat-icon>warning</mat-icon>
            </div>
            <div class="stat-info">
              <h3>{{ stats.expiredSubscriptions }}</h3>
              <p>{{ 'dashboard.expiredSubscriptions' | translate }}</p>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-icon employees">
              <mat-icon>people</mat-icon>
            </div>
            <div class="stat-info">
              <h3>{{ stats.totalEmployees }}</h3>
              <p>{{ 'dashboard.totalEmployees' | translate }}</p>
            </div>
          </mat-card-content>
        </mat-card>
      </div>

      <div class="charts-row">
        <mat-card class="chart-card">
          <mat-card-header>
            <mat-card-title>{{ 'dashboard.subscriptionsByPackage' | translate }}</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <canvas baseChart
              [type]="'doughnut'"
              [data]="subscriptionChartData"
              [options]="chartOptions">
            </canvas>
          </mat-card-content>
        </mat-card>

        <mat-card class="chart-card">
          <mat-card-header>
            <mat-card-title>{{ 'dashboard.monthlyRevenue' | translate }}</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <canvas baseChart
              [type]="'line'"
              [data]="revenueChartData"
              [options]="lineChartOptions">
            </canvas>
          </mat-card-content>
        </mat-card>
      </div>

      <div class="recent-section">
        <mat-card>
          <mat-card-header>
            <mat-card-title>{{ 'dashboard.recentCompanies' | translate }}</mat-card-title>
            <button mat-button color="primary" routerLink="/companies">
              {{ 'common.viewAll' | translate }}
            </button>
          </mat-card-header>
          <mat-card-content>
            <table mat-table [dataSource]="recentCompanies" class="recent-table">
              <ng-container matColumnDef="name">
                <th mat-header-cell *matHeaderCellDef>{{ 'company.name' | translate }}</th>
                <td mat-cell *matCellDef="let company">{{ company.name }}</td>
              </ng-container>

              <ng-container matColumnDef="email">
                <th mat-header-cell *matHeaderCellDef>{{ 'company.email' | translate }}</th>
                <td mat-cell *matCellDef="let company">{{ company.email }}</td>
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
                <td mat-cell *matCellDef="let company">{{ company.employeeCount }}</td>
              </ng-container>

              <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
              <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
            </table>
          </mat-card-content>
        </mat-card>
      </div>
    </div>
  `,
  styles: [`
    .dashboard-container {
      h1 {
        margin-bottom: 24px;
      }
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 24px;
      margin-bottom: 24px;
    }

    .stat-card {
      mat-card-content {
        display: flex;
        align-items: center;
        padding: 24px;
      }

      .stat-icon {
        width: 60px;
        height: 60px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 16px;

        mat-icon {
          font-size: 28px;
          width: 28px;
          height: 28px;
          color: white;
        }

        &.companies { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        &.active { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); }
        &.warning { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
        &.employees { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
      }

      .stat-info {
        h3 {
          font-size: 32px;
          font-weight: 600;
          margin: 0;
        }

        p {
          margin: 0;
          color: #666;
        }
      }
    }

    .charts-row {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
      gap: 24px;
      margin-bottom: 24px;
    }

    .chart-card {
      mat-card-content {
        height: 300px;
        display: flex;
        align-items: center;
        justify-content: center;
      }
    }

    .recent-table {
      width: 100%;
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
    }
  `]
})
export class DashboardComponent implements OnInit {
  private companyService = inject(CompanyService);

  displayedColumns = ['name', 'email', 'status', 'employees'];

  stats = {
    totalCompanies: 0,
    activeCompanies: 0,
    expiredSubscriptions: 0,
    totalEmployees: 0,
    revenueThisMonth: 0,
    revenueGrowth: 0
  };

  recentCompanies: any[] = [];

  subscriptionChartData: ChartConfiguration['data'] = {
    labels: ['Basic', 'Professional', 'Enterprise'],
    datasets: [{
      data: [30, 45, 25],
      backgroundColor: ['#667eea', '#11998e', '#f5576c']
    }]
  };

  revenueChartData: ChartConfiguration['data'] = {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    datasets: [{
      data: [12000, 15000, 18000, 22000, 25000, 28000],
      borderColor: '#667eea',
      backgroundColor: 'rgba(102, 126, 234, 0.1)',
      fill: true,
      tension: 0.4
    }]
  };

  chartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false
  };

  lineChartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: false
      }
    }
  };

  ngOnInit(): void {
    this.loadStatistics();
    this.loadRecentCompanies();
  }

  private loadStatistics(): void {
    this.companyService.getStatistics().subscribe((data) => {
      this.stats = data;
    });
  }

  private loadRecentCompanies(): void {
    this.companyService.getCompanies({ page: 1, pageSize: 5 }).subscribe((response) => {
      this.recentCompanies = response.items;
    });
  }
}
