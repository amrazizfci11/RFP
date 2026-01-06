import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { Store } from '@ngrx/store';
import { TranslateModule, TranslateService } from '@ngx-translate/core';

import { selectUser } from '../../store/auth/auth.selectors';
import { AuthActions } from '../../store/auth/auth.actions';

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [
    CommonModule,
    RouterOutlet,
    RouterLink,
    RouterLinkActive,
    MatSidenavModule,
    MatToolbarModule,
    MatListModule,
    MatIconModule,
    MatButtonModule,
    MatMenuModule,
    TranslateModule
  ],
  template: `
    <mat-sidenav-container class="layout-container">
      <mat-sidenav #sidenav mode="side" opened class="sidenav">
        <div class="logo-container">
          <img src="assets/images/logo.png" alt="Logo" class="logo" />
          <h2>Admin Portal</h2>
        </div>

        <mat-nav-list>
          <a mat-list-item routerLink="/dashboard" routerLinkActive="active">
            <mat-icon>dashboard</mat-icon>
            <span>{{ 'menu.dashboard' | translate }}</span>
          </a>
          <a mat-list-item routerLink="/companies" routerLinkActive="active">
            <mat-icon>business</mat-icon>
            <span>{{ 'menu.companies' | translate }}</span>
          </a>
          <a mat-list-item routerLink="/subscriptions" routerLinkActive="active">
            <mat-icon>card_membership</mat-icon>
            <span>{{ 'menu.subscriptions' | translate }}</span>
          </a>
          <a mat-list-item routerLink="/packages" routerLinkActive="active">
            <mat-icon>inventory_2</mat-icon>
            <span>{{ 'menu.packages' | translate }}</span>
          </a>
          <a mat-list-item routerLink="/analytics" routerLinkActive="active">
            <mat-icon>analytics</mat-icon>
            <span>{{ 'menu.analytics' | translate }}</span>
          </a>
          <a mat-list-item routerLink="/users" routerLinkActive="active">
            <mat-icon>people</mat-icon>
            <span>{{ 'menu.users' | translate }}</span>
          </a>
          <a mat-list-item routerLink="/settings" routerLinkActive="active">
            <mat-icon>settings</mat-icon>
            <span>{{ 'menu.settings' | translate }}</span>
          </a>
        </mat-nav-list>
      </mat-sidenav>

      <mat-sidenav-content>
        <mat-toolbar color="primary">
          <button mat-icon-button (click)="sidenav.toggle()">
            <mat-icon>menu</mat-icon>
          </button>

          <span class="spacer"></span>

          <button mat-icon-button [matMenuTriggerFor]="langMenu">
            <mat-icon>language</mat-icon>
          </button>
          <mat-menu #langMenu="matMenu">
            <button mat-menu-item (click)="switchLanguage('en')">English</button>
            <button mat-menu-item (click)="switchLanguage('ar')">العربية</button>
          </mat-menu>

          <button mat-icon-button [matMenuTriggerFor]="userMenu">
            <mat-icon>account_circle</mat-icon>
          </button>
          <mat-menu #userMenu="matMenu">
            @if (user$ | async; as user) {
              <div class="user-info">
                <strong>{{ user.name }}</strong>
                <small>{{ user.email }}</small>
              </div>
            }
            <mat-divider></mat-divider>
            <a mat-menu-item routerLink="/profile">
              <mat-icon>person</mat-icon>
              <span>{{ 'menu.profile' | translate }}</span>
            </a>
            <button mat-menu-item (click)="logout()">
              <mat-icon>logout</mat-icon>
              <span>{{ 'menu.logout' | translate }}</span>
            </button>
          </mat-menu>
        </mat-toolbar>

        <main class="content">
          <router-outlet></router-outlet>
        </main>
      </mat-sidenav-content>
    </mat-sidenav-container>
  `,
  styles: [`
    .layout-container {
      height: 100vh;
    }

    .sidenav {
      width: 250px;
      background: #fafafa;
    }

    .logo-container {
      display: flex;
      align-items: center;
      padding: 16px;
      border-bottom: 1px solid #e0e0e0;

      .logo {
        width: 40px;
        height: 40px;
        margin-right: 12px;
      }

      h2 {
        margin: 0;
        font-size: 18px;
      }
    }

    mat-nav-list {
      a {
        mat-icon {
          margin-right: 12px;
        }

        &.active {
          background: rgba(63, 81, 181, 0.1);
          color: #3f51b5;
        }
      }
    }

    .spacer {
      flex: 1;
    }

    .content {
      padding: 24px;
      background: #f5f5f5;
      min-height: calc(100vh - 64px);
    }

    .user-info {
      padding: 16px;
      display: flex;
      flex-direction: column;

      strong {
        font-size: 14px;
      }

      small {
        color: #666;
      }
    }
  `]
})
export class MainLayoutComponent {
  private store = inject(Store);
  private translate = inject(TranslateService);

  user$ = this.store.select(selectUser);

  switchLanguage(lang: string): void {
    this.translate.use(lang);
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
  }

  logout(): void {
    this.store.dispatch(AuthActions.logout());
  }
}
