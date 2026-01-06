import { Routes } from '@angular/router';

export const COMPANY_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./company-list/company-list.component').then(m => m.CompanyListComponent),
    data: { title: 'Companies' }
  },
  {
    path: 'create',
    loadComponent: () => import('./company-form/company-form.component').then(m => m.CompanyFormComponent),
    data: { title: 'Create Company' }
  },
  {
    path: ':id',
    loadComponent: () => import('./company-detail/company-detail.component').then(m => m.CompanyDetailComponent),
    data: { title: 'Company Details' }
  },
  {
    path: ':id/edit',
    loadComponent: () => import('./company-form/company-form.component').then(m => m.CompanyFormComponent),
    data: { title: 'Edit Company' }
  }
];
