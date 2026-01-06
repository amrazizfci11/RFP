import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { Store } from '@ngrx/store';
import { TranslateModule } from '@ngx-translate/core';

import { AuthActions } from '../../../store/auth/auth.actions';
import { selectAuthLoading, selectAuthError } from '../../../store/auth/auth.selectors';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    CommonModule,
    RouterLink,
    ReactiveFormsModule,
    MatCardModule,
    MatInputModule,
    MatFormFieldModule,
    MatButtonModule,
    MatIconModule,
    MatProgressSpinnerModule,
    TranslateModule
  ],
  template: `
    <div class="login-container">
      <mat-card class="login-card">
        <mat-card-header>
          <div class="logo-container">
            <img src="assets/images/logo.png" alt="Logo" class="logo" />
            <h1>{{ 'auth.adminPortal' | translate }}</h1>
          </div>
        </mat-card-header>

        <mat-card-content>
          <form [formGroup]="loginForm" (ngSubmit)="onSubmit()">
            @if (error$ | async; as error) {
              <div class="error-message">
                {{ error }}
              </div>
            }

            <mat-form-field appearance="outline" class="full-width">
              <mat-label>{{ 'auth.username' | translate }}</mat-label>
              <input matInput formControlName="username" autocomplete="username" />
              <mat-icon matPrefix>person</mat-icon>
              @if (loginForm.get('username')?.hasError('required') && loginForm.get('username')?.touched) {
                <mat-error>{{ 'validation.required' | translate }}</mat-error>
              }
            </mat-form-field>

            <mat-form-field appearance="outline" class="full-width">
              <mat-label>{{ 'auth.password' | translate }}</mat-label>
              <input matInput [type]="hidePassword ? 'password' : 'text'"
                     formControlName="password" autocomplete="current-password" />
              <mat-icon matPrefix>lock</mat-icon>
              <button mat-icon-button matSuffix type="button"
                      (click)="hidePassword = !hidePassword">
                <mat-icon>{{ hidePassword ? 'visibility_off' : 'visibility' }}</mat-icon>
              </button>
              @if (loginForm.get('password')?.hasError('required') && loginForm.get('password')?.touched) {
                <mat-error>{{ 'validation.required' | translate }}</mat-error>
              }
            </mat-form-field>

            <div class="forgot-link">
              <a routerLink="../forgot-password">{{ 'auth.forgotPassword' | translate }}</a>
            </div>

            <button mat-raised-button color="primary" type="submit"
                    [disabled]="loginForm.invalid || (loading$ | async)" class="submit-btn">
              @if (loading$ | async) {
                <mat-spinner diameter="20"></mat-spinner>
              } @else {
                {{ 'auth.login' | translate }}
              }
            </button>
          </form>
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: [`
    .login-container {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }

    .login-card {
      width: 100%;
      max-width: 400px;
      margin: 16px;

      mat-card-header {
        display: flex;
        justify-content: center;
        margin-bottom: 24px;
      }

      .logo-container {
        text-align: center;

        .logo {
          width: 80px;
          height: 80px;
          margin-bottom: 16px;
        }

        h1 {
          margin: 0;
          font-size: 24px;
          color: #333;
        }
      }
    }

    .full-width {
      width: 100%;
      margin-bottom: 16px;
    }

    .error-message {
      background: #ffebee;
      color: #c62828;
      padding: 12px;
      border-radius: 4px;
      margin-bottom: 16px;
      font-size: 14px;
    }

    .forgot-link {
      text-align: right;
      margin-bottom: 24px;

      a {
        color: #667eea;
        text-decoration: none;
        font-size: 14px;

        &:hover {
          text-decoration: underline;
        }
      }
    }

    .submit-btn {
      width: 100%;
      padding: 12px;
      font-size: 16px;

      mat-spinner {
        margin: 0 auto;
      }
    }
  `]
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private store = inject(Store);

  loading$ = this.store.select(selectAuthLoading);
  error$ = this.store.select(selectAuthError);

  hidePassword = true;

  loginForm: FormGroup = this.fb.group({
    username: ['', [Validators.required]],
    password: ['', [Validators.required]]
  });

  onSubmit(): void {
    if (this.loginForm.valid) {
      this.store.dispatch(AuthActions.login({
        credentials: this.loginForm.value
      }));
    }
  }
}
