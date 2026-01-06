import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { roleGuard } from './core/guards/role.guard';

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
        path: 'companies',
        loadChildren: () => import('./features/companies/companies.routes').then(m => m.COMPANY_ROUTES),
        canActivate: [roleGuard],
        data: { roles: ['SuperAdmin', 'Admin'] }
      },
      {
        path: 'subscriptions',
        loadChildren: () => import('./features/subscriptions/subscriptions.routes').then(m => m.SUBSCRIPTION_ROUTES),
        canActivate: [roleGuard],
        data: { roles: ['SuperAdmin', 'Admin'] }
      },
      {
        path: 'packages',
        loadChildren: () => import('./features/packages/packages.routes').then(m => m.PACKAGE_ROUTES),
        canActivate: [roleGuard],
        data: { roles: ['SuperAdmin'] }
      },
      {
        path: 'analytics',
        loadComponent: () => import('./features/analytics/analytics.component').then(m => m.AnalyticsComponent),
        canActivate: [roleGuard],
        data: { roles: ['SuperAdmin', 'Admin'], title: 'Analytics' }
      },
      {
        path: 'users',
        loadChildren: () => import('./features/users/users.routes').then(m => m.USER_ROUTES),
        canActivate: [roleGuard],
        data: { roles: ['SuperAdmin'] }
      },
      {
        path: 'settings',
        loadComponent: () => import('./features/settings/settings.component').then(m => m.SettingsComponent),
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
