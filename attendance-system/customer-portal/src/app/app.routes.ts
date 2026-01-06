import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'dashboard',
    pathMatch: 'full'
  },
  {
    path: 'auth',
    loadChildren: () => import('./features/auth/auth.routes').then(m => m.AUTH_ROUTES)
  },
  {
    path: '',
    loadComponent: () => import('./layouts/main-layout/main-layout.component').then(m => m.MainLayoutComponent),
    canActivate: [authGuard],
    children: [
      {
        path: 'dashboard',
        loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent),
        data: { title: 'Dashboard' }
      },
      {
        path: 'employees',
        loadChildren: () => import('./features/employees/employees.routes').then(m => m.EMPLOYEE_ROUTES),
        data: { title: 'Employees' }
      },
      {
        path: 'attendance',
        loadChildren: () => import('./features/attendance/attendance.routes').then(m => m.ATTENDANCE_ROUTES),
        data: { title: 'Attendance' }
      },
      {
        path: 'excuses',
        loadChildren: () => import('./features/excuses/excuses.routes').then(m => m.EXCUSE_ROUTES),
        data: { title: 'Excuses' }
      },
      {
        path: 'vacations',
        loadChildren: () => import('./features/vacations/vacations.routes').then(m => m.VACATION_ROUTES),
        data: { title: 'Vacations' }
      },
      {
        path: 'clarifications',
        loadChildren: () => import('./features/clarifications/clarifications.routes').then(m => m.CLARIFICATION_ROUTES),
        data: { title: 'Clarifications' }
      },
      {
        path: 'reports',
        loadComponent: () => import('./features/reports/reports.component').then(m => m.ReportsComponent),
        data: { title: 'Reports' }
      },
      {
        path: 'messaging',
        loadComponent: () => import('./features/messaging/messaging.component').then(m => m.MessagingComponent),
        data: { title: 'Bulk Messaging' }
      },
      {
        path: 'settings',
        loadChildren: () => import('./features/settings/settings.routes').then(m => m.SETTINGS_ROUTES),
        data: { title: 'Settings' }
      },
      {
        path: 'profile',
        loadComponent: () => import('./features/profile/profile.component').then(m => m.ProfileComponent),
        data: { title: 'Profile' }
      }
    ]
  },
  {
    path: '**',
    loadComponent: () => import('./shared/components/not-found/not-found.component').then(m => m.NotFoundComponent)
  }
];
