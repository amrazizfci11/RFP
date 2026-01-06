import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatTableModule } from '@angular/material/table';
import { MatStepperModule } from '@angular/material/stepper';
import { TranslateModule } from '@ngx-translate/core';
import { ToastrService } from 'ngx-toastr';

import { EmployeeService, ImportResult } from '../../../core/services/employee.service';

@Component({
  selector: 'app-employee-import',
  standalone: true,
  imports: [
    CommonModule,
    RouterLink,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatProgressBarModule,
    MatTableModule,
    MatStepperModule,
    TranslateModule
  ],
  template: `
    <div class="import-container">
      <div class="header">
        <h1>{{ 'employees.importTitle' | translate }}</h1>
        <button mat-stroked-button routerLink="/employees">
          <mat-icon>arrow_back</mat-icon>
          {{ 'common.back' | translate }}
        </button>
      </div>

      <mat-stepper [linear]="true" #stepper>
        <mat-step [completed]="fileSelected">
          <ng-template matStepLabel>{{ 'import.selectFile' | translate }}</ng-template>

          <mat-card class="step-card">
            <mat-card-content>
              <div class="upload-section">
                <div class="upload-area"
                     (dragover)="onDragOver($event)"
                     (dragleave)="onDragLeave($event)"
                     (drop)="onDrop($event)"
                     [class.dragover]="isDragOver"
                     (click)="fileInput.click()">
                  <mat-icon>cloud_upload</mat-icon>
                  <p>{{ 'import.dropFile' | translate }}</p>
                  <span>{{ 'import.orBrowse' | translate }}</span>
                  <input #fileInput type="file" accept=".xlsx,.xls,.csv" hidden
                         (change)="onFileSelected($event)" />
                </div>

                @if (selectedFile) {
                  <div class="selected-file">
                    <mat-icon>description</mat-icon>
                    <span>{{ selectedFile.name }}</span>
                    <button mat-icon-button (click)="clearFile()">
                      <mat-icon>close</mat-icon>
                    </button>
                  </div>
                }

                <div class="template-section">
                  <p>{{ 'import.templateHint' | translate }}</p>
                  <button mat-stroked-button (click)="downloadTemplate()">
                    <mat-icon>download</mat-icon>
                    {{ 'import.downloadTemplate' | translate }}
                  </button>
                </div>
              </div>
            </mat-card-content>
            <mat-card-actions align="end">
              <button mat-raised-button color="primary" matStepperNext
                      [disabled]="!fileSelected">
                {{ 'common.next' | translate }}
              </button>
            </mat-card-actions>
          </mat-card>
        </mat-step>

        <mat-step [completed]="importComplete">
          <ng-template matStepLabel>{{ 'import.process' | translate }}</ng-template>

          <mat-card class="step-card">
            <mat-card-content>
              @if (importing) {
                <div class="importing-section">
                  <mat-progress-bar mode="indeterminate"></mat-progress-bar>
                  <p>{{ 'import.processing' | translate }}</p>
                </div>
              }

              @if (importResult) {
                <div class="result-section">
                  <div class="result-summary">
                    <div class="result-stat success">
                      <mat-icon>check_circle</mat-icon>
                      <div>
                        <h3>{{ importResult.successCount }}</h3>
                        <p>{{ 'import.imported' | translate }}</p>
                      </div>
                    </div>
                    <div class="result-stat error" *ngIf="importResult.errorCount > 0">
                      <mat-icon>error</mat-icon>
                      <div>
                        <h3>{{ importResult.errorCount }}</h3>
                        <p>{{ 'import.errors' | translate }}</p>
                      </div>
                    </div>
                    <div class="result-stat total">
                      <mat-icon>list</mat-icon>
                      <div>
                        <h3>{{ importResult.totalRows }}</h3>
                        <p>{{ 'import.totalRows' | translate }}</p>
                      </div>
                    </div>
                  </div>

                  @if (importResult.errors.length > 0) {
                    <div class="errors-section">
                      <h4>{{ 'import.errorDetails' | translate }}</h4>
                      <table mat-table [dataSource]="importResult.errors">
                        <ng-container matColumnDef="row">
                          <th mat-header-cell *matHeaderCellDef>{{ 'import.row' | translate }}</th>
                          <td mat-cell *matCellDef="let error">{{ error.row }}</td>
                        </ng-container>
                        <ng-container matColumnDef="message">
                          <th mat-header-cell *matHeaderCellDef>{{ 'import.error' | translate }}</th>
                          <td mat-cell *matCellDef="let error">{{ error.message }}</td>
                        </ng-container>
                        <tr mat-header-row *matHeaderRowDef="['row', 'message']"></tr>
                        <tr mat-row *matRowDef="let row; columns: ['row', 'message'];"></tr>
                      </table>
                    </div>
                  }
                </div>
              }
            </mat-card-content>
            <mat-card-actions align="end">
              <button mat-stroked-button matStepperPrevious [disabled]="importing">
                {{ 'common.back' | translate }}
              </button>
              @if (!importing && !importResult) {
                <button mat-raised-button color="primary" (click)="startImport()">
                  {{ 'import.startImport' | translate }}
                </button>
              }
              @if (importComplete) {
                <button mat-raised-button color="primary" routerLink="/employees">
                  {{ 'import.viewEmployees' | translate }}
                </button>
              }
            </mat-card-actions>
          </mat-card>
        </mat-step>
      </mat-stepper>
    </div>
  `,
  styles: [`
    .import-container {
      .header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
        h1 { margin: 0; }
      }

      .step-card {
        margin-top: 24px;
      }

      .upload-area {
        border: 2px dashed #ccc;
        border-radius: 8px;
        padding: 48px;
        text-align: center;
        cursor: pointer;
        transition: all 0.3s ease;

        &:hover, &.dragover {
          border-color: #3f51b5;
          background: rgba(63, 81, 181, 0.05);
        }

        mat-icon {
          font-size: 48px;
          width: 48px;
          height: 48px;
          color: #666;
        }

        p {
          margin: 16px 0 8px;
          font-size: 16px;
        }

        span {
          color: #3f51b5;
          cursor: pointer;
        }
      }

      .selected-file {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 12px;
        background: #f5f5f5;
        border-radius: 4px;
        margin-top: 16px;

        mat-icon {
          color: #3f51b5;
        }

        span {
          flex: 1;
        }
      }

      .template-section {
        margin-top: 24px;
        padding-top: 24px;
        border-top: 1px solid #eee;
        text-align: center;

        p {
          color: #666;
          margin-bottom: 12px;
        }
      }

      .importing-section {
        text-align: center;
        padding: 48px;

        p {
          margin-top: 16px;
          color: #666;
        }
      }

      .result-summary {
        display: flex;
        gap: 24px;
        justify-content: center;
        margin-bottom: 24px;

        .result-stat {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 16px 24px;
          border-radius: 8px;

          mat-icon {
            font-size: 32px;
            width: 32px;
            height: 32px;
          }

          h3 {
            margin: 0;
            font-size: 24px;
          }

          p {
            margin: 0;
            font-size: 14px;
          }

          &.success {
            background: #e8f5e9;
            mat-icon { color: #2e7d32; }
          }

          &.error {
            background: #ffebee;
            mat-icon { color: #c62828; }
          }

          &.total {
            background: #e3f2fd;
            mat-icon { color: #1976d2; }
          }
        }
      }

      .errors-section {
        h4 {
          margin-bottom: 16px;
        }

        table {
          width: 100%;
        }
      }
    }
  `]
})
export class EmployeeImportComponent {
  private employeeService = inject(EmployeeService);
  private toastr = inject(ToastrService);

  selectedFile: File | null = null;
  isDragOver = false;
  importing = false;
  importResult: ImportResult | null = null;

  get fileSelected(): boolean {
    return this.selectedFile !== null;
  }

  get importComplete(): boolean {
    return this.importResult !== null;
  }

  onDragOver(event: DragEvent): void {
    event.preventDefault();
    this.isDragOver = true;
  }

  onDragLeave(event: DragEvent): void {
    event.preventDefault();
    this.isDragOver = false;
  }

  onDrop(event: DragEvent): void {
    event.preventDefault();
    this.isDragOver = false;
    const files = event.dataTransfer?.files;
    if (files && files.length > 0) {
      this.handleFile(files[0]);
    }
  }

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.handleFile(input.files[0]);
    }
  }

  handleFile(file: File): void {
    const validTypes = ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                        'application/vnd.ms-excel', 'text/csv'];
    if (!validTypes.includes(file.type) && !file.name.endsWith('.xlsx') && !file.name.endsWith('.csv')) {
      this.toastr.error('Please select a valid Excel or CSV file');
      return;
    }
    this.selectedFile = file;
  }

  clearFile(): void {
    this.selectedFile = null;
    this.importResult = null;
  }

  downloadTemplate(): void {
    this.employeeService.downloadTemplate().subscribe((blob) => {
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'employee_import_template.xlsx';
      a.click();
      window.URL.revokeObjectURL(url);
    });
  }

  startImport(): void {
    if (!this.selectedFile) return;

    this.importing = true;
    this.employeeService.importFromExcel(this.selectedFile).subscribe({
      next: (result) => {
        this.importResult = result;
        this.importing = false;
        if (result.errorCount === 0) {
          this.toastr.success(`Successfully imported ${result.successCount} employees`);
        } else {
          this.toastr.warning(`Imported ${result.successCount} employees with ${result.errorCount} errors`);
        }
      },
      error: (error) => {
        this.importing = false;
        this.toastr.error(error.message || 'Import failed');
      }
    });
  }
}
