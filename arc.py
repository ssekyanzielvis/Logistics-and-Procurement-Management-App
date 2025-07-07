import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle
import numpy as np
import seaborn as sns
from matplotlib.patches import Rectangle, Arrow
import matplotlib.gridspec as gridspec

# Set up the plotting style
plt.style.use('seaborn-v0_8')
sns.set_palette("husl")

# 1. SYSTEM ARCHITECTURE OVERVIEW
def create_system_architecture():
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(5, 9.5, 'Logistics Management System Architecture', 
            fontsize=20, fontweight='bold', ha='center')
    
    # Mobile App Layer
    mobile_box = FancyBboxPatch((0.5, 7.5), 2, 1.5, 
                                boxstyle="round,pad=0.1", 
                                facecolor='lightblue', 
                                edgecolor='navy', linewidth=2)
    ax.add_patch(mobile_box)
    ax.text(1.5, 8.2, 'Mobile App\n(Flutter)', fontsize=12, ha='center', fontweight='bold')
    
    # Web Dashboard
    web_box = FancyBboxPatch((3, 7.5), 2, 1.5, 
                             boxstyle="round,pad=0.1", 
                             facecolor='lightgreen', 
                             edgecolor='darkgreen', linewidth=2)
    ax.add_patch(web_box)
    ax.text(4, 8.2, 'Admin Dashboard\n(Web)', fontsize=12, ha='center', fontweight='bold')
    
    # API Gateway
    api_box = FancyBboxPatch((1.5, 5.5), 3, 1, 
                             boxstyle="round,pad=0.1", 
                             facecolor='orange', 
                             edgecolor='darkorange', linewidth=2)
    ax.add_patch(api_box)
    ax.text(3, 6, 'API Gateway\n(Supabase)', fontsize=12, ha='center', fontweight='bold')
    
    # Database
    db_box = FancyBboxPatch((0.5, 3.5), 2, 1.5, 
                            boxstyle="round,pad=0.1", 
                            facecolor='lightcoral', 
                            edgecolor='darkred', linewidth=2)
    ax.add_patch(db_box)
    ax.text(1.5, 4.2, 'PostgreSQL\nDatabase', fontsize=12, ha='center', fontweight='bold')
    
    # File Storage
    storage_box = FancyBboxPatch((3, 3.5), 2, 1.5, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor='lightyellow', 
                                 edgecolor='gold', linewidth=2)
    ax.add_patch(storage_box)
    ax.text(4, 4.2, 'File Storage\n(Images/Documents)', fontsize=12, ha='center', fontweight='bold')
    
    # External Services
    maps_box = FancyBboxPatch((6, 7), 1.5, 1, 
                              boxstyle="round,pad=0.1", 
                              facecolor='lightpink', 
                              edgecolor='purple', linewidth=2)
    ax.add_patch(maps_box)
    ax.text(6.75, 7.5, 'Google Maps\nAPI', fontsize=10, ha='center', fontweight='bold')
    
    notification_box = FancyBboxPatch((6, 5.5), 1.5, 1, 
                                      boxstyle="round,pad=0.1", 
                                      facecolor='lightgray', 
                                      edgecolor='black', linewidth=2)
    ax.add_patch(notification_box)
    ax.text(6.75, 6, 'Push\nNotifications', fontsize=10, ha='center', fontweight='bold')
    
    # Real-time Services
    realtime_box = FancyBboxPatch((6, 4), 1.5, 1, 
                                  boxstyle="round,pad=0.1", 
                                  facecolor='lightsteelblue', 
                                  edgecolor='steelblue', linewidth=2)
    ax.add_patch(realtime_box)
    ax.text(6.75, 4.5, 'Real-time\nTracking', fontsize=10, ha='center', fontweight='bold')
    
    # Security Layer
    security_box = FancyBboxPatch((0.5, 1.5), 7, 1, 
                                  boxstyle="round,pad=0.1", 
                                  facecolor='mistyrose', 
                                  edgecolor='red', linewidth=3)
    ax.add_patch(security_box)
    ax.text(4, 2, 'Security Layer: Authentication, Authorization, Encryption', 
            fontsize=12, ha='center', fontweight='bold')
    
    # Add arrows to show connections
    arrows = [
        # Mobile to API
        ((1.5, 7.5), (2.5, 6.5)),
        # Web to API
        ((4, 7.5), (3.5, 6.5)),
        # API to Database
        ((2.5, 5.5), (1.5, 5)),
        # API to Storage
        ((3.5, 5.5), (4, 5)),
        # API to External Services
        ((4.5, 6), (6, 7)),
        ((4.5, 6), (6, 6)),
        ((4.5, 6), (6, 4.5)),
    ]
    
    for start, end in arrows:
        arrow = ConnectionPatch(start, end, "data", "data",
                               arrowstyle="->", shrinkA=5, shrinkB=5,
                               mutation_scale=20, fc="black", lw=2)
        ax.add_patch(arrow)
    
    # Add legend
    legend_elements = [
        patches.Patch(color='lightblue', label='User Interface'),
        patches.Patch(color='orange', label='API Layer'),
        patches.Patch(color='lightcoral', label='Data Storage'),
        patches.Patch(color='lightpink', label='External Services'),
        patches.Patch(color='mistyrose', label='Security Layer')
    ]
    ax.legend(handles=legend_elements, loc='upper right', bbox_to_anchor=(0.98, 0.98))
    
    plt.tight_layout()
    plt.savefig('system_architecture.png', dpi=300, bbox_inches='tight')
    plt.show()

# 2. USER INTERACTION FLOW
def create_user_interaction_flow():
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(6, 9.5, 'User Interaction Flow Diagram', 
            fontsize=18, fontweight='bold', ha='center')
    
    # User types
    users = [
        {'name': 'Admin', 'pos': (1, 8), 'color': 'red'},
        {'name': 'Client', 'pos': (6, 8), 'color': 'blue'},
        {'name': 'Driver', 'pos': (11, 8), 'color': 'green'}
    ]
    
    for user in users:
        circle = Circle(user['pos'], 0.5, facecolor=user['color'], alpha=0.7)
        ax.add_patch(circle)
        ax.text(user['pos'][0], user['pos'][1], user['name'], 
                ha='center', va='center', fontweight='bold', color='white')
    
    # System components
    components = [
        {'name': 'User\nManagement', 'pos': (1, 6), 'color': 'lightcoral'},
        {'name': 'Consignment\nCreation', 'pos': (3, 6), 'color': 'lightblue'},
        {'name': 'Assignment\nSystem', 'pos': (5, 6), 'color': 'lightgreen'},
        {'name': 'GPS\nTracking', 'pos': (7, 6), 'color': 'lightyellow'},
        {'name': 'Messaging\nSystem', 'pos': (9, 6), 'color': 'lightpink'},
        {'name': 'Fuel\nManagement', 'pos': (11, 6), 'color': 'lightgray'}
    ]
    
    for comp in components:
        box = FancyBboxPatch((comp['pos'][0]-0.6, comp['pos'][1]-0.4), 1.2, 0.8,
                             boxstyle="round,pad=0.1", 
                             facecolor=comp['color'], 
                             edgecolor='black', linewidth=1)
        ax.add_patch(box)
        ax.text(comp['pos'][0], comp['pos'][1], comp['name'], 
                ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Database
    db_box = FancyBboxPatch((5, 3.5), 2, 1, 
                            boxstyle="round,pad=0.1", 
                            facecolor='orange', 
                            edgecolor='darkorange', linewidth=2)
    ax.add_patch(db_box)
    ax.text(6, 4, 'Central Database', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # User interactions (arrows)
    interactions = [
        # Admin interactions
        ((1, 7.5), (1, 6.4)),  # User Management
        ((1, 7.5), (3, 6.4)),  # Consignment Creation
        ((1, 7.5), (5, 6.4)),  # Assignment
        
        # Client interactions
        ((6, 7.5), (3, 6.4)),  # Consignment Creation
        ((6, 7.5), (7, 6.4)),  # GPS Tracking
        ((6, 7.5), (9, 6.4)),  # Messaging
        
        # Driver interactions
        ((11, 7.5), (7, 6.4)),  # GPS Tracking
        ((11, 7.5), (9, 6.4)),  # Messaging
        ((11, 7.5), (11, 6.4)), # Fuel Management
    ]
    
    for start, end in interactions:
        arrow = ConnectionPatch(start, end, "data", "data",
                               arrowstyle="->", shrinkA=5, shrinkB=5,
                               mutation_scale=15, fc="gray", lw=1.5)
        ax.add_patch(arrow)
    
    # Component to database connections
    for comp in components:
        start = (comp['pos'][0], comp['pos'][1] - 0.4)
        end = (6, 4.5)
        arrow = ConnectionPatch(start, end, "data", "data",
                               arrowstyle="->", shrinkA=5, shrinkB=5,
                               mutation_scale=10, fc="orange", lw=1, alpha=0.7)
        ax.add_patch(arrow)
    
    # Add process flow
    ax.text(6, 2, 'Process Flow: User Action → System Processing → Database Update → Real-time Notification', 
            ha='center', fontsize=12, fontweight='bold', 
            bbox=dict(boxstyle="round,pad=0.3", facecolor='lightyellow'))
    
    plt.tight_layout()
    plt.savefig('user_interaction_flow.png', dpi=300, bbox_inches='tight')
    plt.show()

# 3. SECURITY ARCHITECTURE
def create_security_architecture():
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(5, 9.5, 'Security Architecture & Data Protection', 
            fontsize=18, fontweight='bold', ha='center')
    
    # Security layers (concentric rectangles)
    layers = [
        {'name': 'Physical Security', 'rect': (0.5, 0.5, 9, 9), 'color': 'lightgray', 'alpha': 0.3},
        {'name': 'Network Security', 'rect': (1, 1, 8, 8), 'color': 'lightblue', 'alpha': 0.4},
        {'name': 'Application Security', 'rect': (1.5, 1.5, 7, 7), 'color': 'lightgreen', 'alpha': 0.5},
        {'name': 'Data Security', 'rect': (2, 2, 6, 6), 'color': 'lightyellow', 'alpha': 0.6},
        {'name': 'User Security', 'rect': (2.5, 2.5, 5, 5), 'color': 'lightcoral', 'alpha': 0.7}
    ]
    
    for i, layer in enumerate(layers):
        rect = Rectangle((layer['rect'][0], layer['rect'][1]), 
                        layer['rect'][2], layer['rect'][3],
                        facecolor=layer['color'], alpha=layer['alpha'],
                        edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(layer['rect'][0] + 0.1, layer['rect'][1] + layer['rect'][3] - 0.3, 
                layer['name'], fontsize=10, fontweight='bold')
    
    # Security components
    security_components = [
        {'name': 'Multi-Factor\nAuthentication', 'pos': (3, 7), 'icon': '🔐'},
        {'name': 'Role-Based\nAccess Control', 'pos': (7, 7), 'icon': '👥'},
        {'name': 'Data\nEncryption', 'pos': (3, 5), 'icon': '🔒'},
        {'name': 'API\nSecurity', 'pos': (7, 5), 'icon': '🛡️'},
        {'name': 'Audit\nLogging', 'pos': (3, 3), 'icon': '📝'},
        {'name': 'Backup &\nRecovery', 'pos': (7, 3), 'icon': '💾'}
    ]
    
    for comp in security_components:
        box = FancyBboxPatch((comp['pos'][0]-0.7, comp['pos'][1]-0.4), 1.4, 0.8,
                             boxstyle="round,pad=0.1", 
                             facecolor='white', 
                             edgecolor='darkred', linewidth=2)
        ax.add_patch(box)
        ax.text(comp['pos'][0], comp['pos'][1]+0.1, comp['icon'], 
                ha='center', va='center', fontsize=16)
        ax.text(comp['pos'][0], comp['pos'][1]-0.2, comp['name'], 
                ha='center', va='center', fontsize=8, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('security_architecture.png', dpi=300, bbox_inches='tight')
    plt.show()

# 4. USER PRIVILEGE MATRIX
def create_user_privilege_matrix():
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    
    # Define users and their privileges
    users = ['Admin', 'Other Admin', 'Client', 'Driver']
    features = [
        'User Management', 'Create Consignments', 'Assign Drivers', 
        'View All Consignments', 'GPS Tracking', 'Messaging', 
        'Fuel Management', 'Reports & Analytics', 'System Settings',
        'Profile Management', 'View Own Data', 'Update Status'
    ]
    
    # Privilege matrix (1 = Full Access, 0.5 = Limited Access, 0 = No Access)
    privileges = np.array([
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],  # Admin
        [0.5, 1, 1, 1, 1, 1, 0.5, 1, 0.5, 1, 1, 1],  # Other Admin
        [0, 1, 0, 0.5, 1, 1, 0, 0.5, 0, 1, 1, 0.5],  # Client
        [0, 0, 0, 0.5, 1, 1, 1, 0, 0, 1, 1, 1]   # Driver
    ])
    
    # Create heatmap
    im = ax.imshow(privileges, cmap='RdYlGn', aspect='auto', vmin=0, vmax=1)
    
    # Set ticks and labels
    ax.set_xticks(np.arange(len(features)))
    ax.set_yticks(np.arange(len(users)))
    ax.set_xticklabels(features, rotation=45, ha='right')
    ax.set_yticklabels(users)
    
    # Add text annotations
    for i in range(len(users)):
        for j in range(len(features)):
            if privileges[i, j] == 1:
                text = 'Full'
                color = 'white'
            elif privileges[i, j] == 0.5:
                text = 'Limited'
                color = 'black'
            else:
                text = 'None'
                color = 'white'
            
            ax.text(j, i, text, ha='center', va='center', 
                   color=color, fontweight='bold', fontsize=8)
    
    # Add colorbar
    cbar = plt.colorbar(im, ax=ax)
    cbar.set_label('Access Level', rotation=270, labelpad=20)
    
    ax.set_title('User Privilege Matrix - Access Control Overview', 
                fontsize=16, fontweight='bold', pad=20)
    
    plt.tight_layout()
    plt.savefig('user_privilege_matrix.png', dpi=300, bbox_inches='tight')
    plt.show()

# 5. SYSTEM EVALUATION DASHBOARD
def create_system_evaluation():
    fig = plt.figure(figsize=(16, 12))
    gs = gridspec.GridSpec(3, 3, figure=fig)
    
    # Main title
    fig.suptitle('System Performance & Evaluation Dashboard', 
                fontsize=20, fontweight='bold')
    
    # 1. Performance Metrics
    ax1 = fig.add_subplot(gs[0, 0])
    metrics = ['Response Time', 'Uptime', 'User Satisfaction', 'Data Accuracy']
    values = [85, 99.9, 92, 98]
    colors = ['#ff9999', '#66b3ff', '#99ff99', '#ffcc99']
    
    bars = ax1.bar(metrics, values, color=colors)
    ax1.set_title('Key Performance Indicators', fontweight='bold')
    ax1.set_ylabel('Percentage (%)')
    ax1.set_ylim(0, 100)
    
    # Add value labels on bars
    for bar, value in zip(bars, values):
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height + 1,
                f'{value}%', ha='center', va='bottom', fontweight='bold')
    
    # 2. User Activity
    ax2 = fig.add_subplot(gs[0, 1])
    user_types = ['Admin', 'Client', 'Driver']
    active_users = [5, 150, 75]
    
    wedges, texts, autotexts = ax2.pie(active_users, labels=user_types, 
                                      autopct='%1.1f%%', startangle=90,
                                      colors=['#ff6b6b', '#4ecdc4', '#45b7d1'])
    ax2.set_title('Active Users Distribution', fontweight='bold')
    
    # 3. System Load
    ax3 = fig.add_subplot(gs[0, 2])
    hours = np.arange(0, 24)
    load = np.sin(hours * np.pi / 12) * 30 + 50 + np.random.normal(0, 5, 24)
    load = np.clip(load, 0, 100)
    
    ax3.plot(hours, load, marker='o', linewidth=2, markersize=4)
    ax3.fill_between(hours, load, alpha=0.3)
    ax3.set_title('24-Hour System Load', fontweight='bold')
    ax3.set_xlabel('Hour of Day')
    ax3.set_ylabel('Load (%)')
    ax3.set_xlim(0, 23)
    ax3.set_ylim(0, 100)
    ax3.grid(True, alpha=0.3)
    
    # 4. Delivery Statistics
    ax4 = fig.add_subplot(gs[1, :])
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
    completed = [120, 135, 158, 142, 167, 189]
    pending = [25, 30, 22, 28, 31, 24]
    cancelled = [8, 12, 15, 10, 9, 11]
    
    x = np.arange(len(months))
    width = 0.25
    
    ax4.bar(x - width, completed, width, label='Completed', color='#2ecc71')
    ax4.bar(x, pending, width, label='Pending', color='#f39c12')
    ax4.bar(x + width, cancelled, width, label='Cancelled', color='#e74c3c')
    
    ax4.set_title('Monthly Delivery Statistics', fontweight='bold')
    ax4.set_xlabel('Month')
    ax4.set_ylabel('Number of Consignments')
    ax4.set_xticks(x)
    ax4.set_xticklabels(months)
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    
    # 5. Security Events
    ax5 = fig.add_subplot(gs[2, 0])
    security_events = ['Login Attempts', 'Failed Logins', 'Blocked IPs', 'Data Breaches']
    event_counts = [1250, 45, 12, 0]
    colors = ['green', 'orange', 'red', 'darkred']
    
    bars = ax5.barh(security_events, event_counts, color=colors)
    ax5.set_title('Security Events (Last 30 Days)', fontweight='bold')
    ax5.set_xlabel('Count')
    
    # 6. Cost Analysis
    ax6 = fig.add_subplot(gs[2, 1])
    cost_categories = ['Infrastructure', 'Development', 'Maintenance', 'Support']
    costs = [15000, 35000, 8000, 12000]
    
    wedges, texts, autotexts = ax6.pie(costs, labels=cost_categories, 
                                      autopct='$%1.0f', startangle=90,
                                      colors=['#3498db', '#9b59b6', '#1abc9c', '#f1c40f'])
    ax6.set_title('Cost Distribution', fontweight='bold')
    
    # 7. System Health
    ax7 = fig.add_subplot(gs[2, 2])
    components = ['Database', 'API', 'Storage', 'Network']
    health_scores = [98, 95, 99, 97]
    
    # Create a radar chart
    angles = np.linspace(0, 2 * np.pi, len(components), endpoint=False)
    health_scores_plot = health_scores + [health_scores[0]]  # Complete the circle
    angles_plot = np.concatenate((angles, [angles[0]]))
    
    ax7 = plt.subplot(gs[2, 2], projection='polar')
    ax7.plot(angles_plot, health_scores_plot, 'o-', linewidth=2, color='#2ecc71')
    ax7.fill(angles_plot, health_scores_plot, alpha=0.25, color='#2ecc71')
    ax7.set_xticks(angles)
    ax7.set_xticklabels(components)
    ax7.set_ylim(0, 100)
    ax7.set_title('System Health Score', fontweight='bold', pad=20)
    
    plt.tight_layout()
    plt.savefig('system_evaluation.png', dpi=300, bbox_inches='tight')
    plt.show()

# 6. USER INTERFACE MOCKUP
def create_ui_mockup():
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle('User Interface Design Overview', fontsize=20, fontweight='bold')
    
    # Define screen layouts for different user types
    screens = [
        {'title': 'Admin Dashboard', 'user': 'Admin', 'pos': (0, 0)},
        {'title': 'Client Home', 'user': 'Client', 'pos': (0, 1)},
        {'title': 'Driver Interface', 'user': 'Driver', 'pos': (0, 2)},
        {'title': 'Consignment Form', 'user': 'Client', 'pos': (1, 0)},
        {'title': 'GPS Tracking', 'user': 'All Users', 'pos': (1, 1)},
        {'title': 'Messaging', 'user': 'All Users', 'pos': (1, 2)}
    ]
    
    for screen in screens:
        ax = axes[screen['pos']]
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 15)
        ax.set_aspect('equal')
        
        # Phone frame
        phone_frame = Rectangle((1, 1), 8, 13, facecolor='black', edgecolor='black')
        ax.add_patch(phone_frame)
        
        # Screen
        screen_area = Rectangle((1.5, 2), 7, 11, facecolor='white', edgecolor='gray')
        ax.add_patch(screen_area)
        
        # Header
        header = Rectangle((1.5, 11.5), 7, 1.5, facecolor='#3498db', edgecolor='none')
        ax.add_patch(header)
        ax.text(5, 12.2, screen['title'], ha='center', va='center', 
                color='white', fontweight='bold', fontsize=10)
        
        # Content based on screen type
        if 'Dashboard' in screen['title']:
            # Dashboard elements
            elements = [
                {'pos': (2, 10), 'size': (2.5, 1), 'color': '#e74c3c', 'text': 'Users\n250'},
                {'pos': (5.5, 10), 'size': (2.5, 1), 'color': '#2ecc71', 'text': 'Active\n45'},
                {'pos': (2, 8.5), 'size': (6, 1), 'color': '#f39c12', 'text': 'Recent Consignments'},
                {'pos': (2, 6), 'size': (6, 2), 'color': '#ecf0f1', 'text': 'Analytics Chart'},
                {'pos': (2, 3.5), 'size': (6, 2), 'color': '#95a5a6', 'text': 'System Status'}
            ]
        elif 'Client' in screen['title']:
            elements = [
                {'pos': (2, 10), 'size': (6, 1), 'color': '#3498db', 'text': 'Create New Consignment'},
                {'pos': (2, 8.5), 'size': (6, 1), 'color': '#2ecc71', 'text': 'Track My Deliveries'},
                {'pos': (2, 7), 'size': (6, 1), 'color': '#f39c12', 'text': 'Message Driver'},
                {'pos': (2, 4), 'size': (6, 2.5), 'color': '#ecf0f1', 'text': 'Recent Orders\n• Order #123\n• Order #124\n• Order #125'}
            ]
        elif 'Driver' in screen['title']:
            elements = [
                {'pos': (2, 10), 'size': (6, 1), 'color': '#e74c3c', 'text': 'Current Delivery'},
                {'pos': (2, 8.5), 'size': (6, 1), 'color': '#2ecc71', 'text': 'Start GPS Tracking'},
                {'pos': (2, 7), 'size': (6, 1), 'color': '#f39c12', 'text': 'Fuel Card Balance'},
                {'pos': (2, 4), 'size': (6, 2.5), 'color': '#ecf0f1', 'text': 'Assigned Orders\n• Pickup: Location A\n• Deliver: Location B\n• Status: In Transit'}
            ]
        elif 'Form' in screen['title']:
            elements = [
                {'pos': (2, 10), 'size': (6, 0.8), 'color': '#ecf0f1', 'text': 'Pickup Location'},
                             {'pos': (2, 9), 'size': (6, 0.8), 'color': '#ecf0f1', 'text': 'Delivery Location'},
                {'pos': (2, 8), 'size': (6, 0.8), 'color': '#ecf0f1', 'text': 'Item Description'},
                {'pos': (2, 7), 'size': (6, 0.8), 'color': '#ecf0f1', 'text': 'Weight (kg)'},
                {'pos': (2, 6), 'size': (6, 0.8), 'color': '#ecf0f1', 'text': 'Special Instructions'},
                {'pos': (2, 4.5), 'size': (6, 1), 'color': '#3498db', 'text': 'Submit Request'},
                {'pos': (2, 3), 'size': (6, 1), 'color': '#95a5a6', 'text': 'Cancel'}
            ]
        elif 'GPS' in screen['title']:
            elements = [
                {'pos': (2, 8), 'size': (6, 4), 'color': '#2ecc71', 'text': 'MAP VIEW\n📍 Current Location\n🚛 Driver Position\n📦 Destination'},
                {'pos': (2, 6), 'size': (6, 1), 'color': '#f39c12', 'text': 'ETA: 25 minutes'},
                {'pos': (2, 4.5), 'size': (6, 1), 'color': '#e74c3c', 'text': 'Distance: 12.5 km'},
                {'pos': (2, 3), 'size': (6, 1), 'color': '#3498db', 'text': 'Refresh Location'}
            ]
        else:  # Messaging
            elements = [
                {'pos': (2, 9), 'size': (6, 3), 'color': '#ecf0f1', 'text': 'Chat Messages\n👤 Driver: On my way\n👤 You: Thank you\n👤 Driver: ETA 20 min'},
                {'pos': (2, 7), 'size': (4.5, 1), 'color': '#bdc3c7', 'text': 'Type message...'},
                {'pos': (6.8, 7), 'size': (1.2, 1), 'color': '#3498db', 'text': 'Send'},
                {'pos': (2, 5.5), 'size': (6, 1), 'color': '#2ecc71', 'text': '📷 Send Photo'},
                {'pos': (2, 4), 'size': (6, 1), 'color': '#f39c12', 'text': '📍 Share Location'}
            ]
        
        # Draw UI elements
        for element in elements:
            rect = Rectangle(element['pos'], element['size'][0], element['size'][1], 
                           facecolor=element['color'], edgecolor='gray', alpha=0.8)
            ax.add_patch(rect)
            ax.text(element['pos'][0] + element['size'][0]/2, 
                   element['pos'][1] + element['size'][1]/2,
                   element['text'], ha='center', va='center', 
                   fontsize=8, fontweight='bold', wrap=True)
        
        # Navigation bar
        nav_bar = Rectangle((1.5, 2), 7, 0.8, facecolor='#34495e', edgecolor='none')
        ax.add_patch(nav_bar)
        nav_items = ['🏠', '📦', '💬', '👤']
        for i, item in enumerate(nav_items):
            ax.text(2.5 + i*1.5, 2.4, item, ha='center', va='center', 
                   color='white', fontsize=12)
        
        ax.set_title(f'{screen["user"]} Interface', fontweight='bold', pad=10)
        ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('ui_mockup.png', dpi=300, bbox_inches='tight')
    plt.show()

# 7. FILE STRUCTURE DIAGRAM
def create_file_structure():
    fig, ax = plt.subplots(1, 1, figsize=(14, 16))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 20)
    ax.axis('off')
    
    # Title
    ax.text(5, 19.5, 'Project File Structure', fontsize=18, fontweight='bold', ha='center')
    
    # File structure data
    structure = [
        {'name': '📁 logistics_app/', 'level': 0, 'y': 18.5},
        {'name': '├── 📁 lib/', 'level': 1, 'y': 18},
        {'name': '│   ├── 📁 models/', 'level': 2, 'y': 17.5},
        {'name': '│   │   ├── 📄 user.dart', 'level': 3, 'y': 17},
        {'name': '│   │   ├── 📄 consignment.dart', 'level': 3, 'y': 16.5},
        {'name': '│   │   └── 📄 message.dart', 'level': 3, 'y': 16},
        {'name': '│   ├── 📁 services/', 'level': 2, 'y': 15.5},
        {'name': '│   │   ├── 📄 auth_service.dart', 'level': 3, 'y': 15},
        {'name': '│   │   ├── 📄 consignment_service.dart', 'level': 3, 'y': 14.5},
        {'name': '│   │   ├── 📄 location_service.dart', 'level': 3, 'y': 14},
        {'name': '│   │   └── 📄 messaging_service.dart', 'level': 3, 'y': 13.5},
        {'name': '│   ├── 📁 screens/', 'level': 2, 'y': 13},
        {'name': '│   │   ├── 📁 admin/', 'level': 3, 'y': 12.5},
        {'name': '│   │   │   ├── 📄 dashboard.dart', 'level': 4, 'y': 12},
        {'name': '│   │   │   └── 📄 user_management.dart', 'level': 4, 'y': 11.5},
        {'name': '│   │   ├── 📁 client/', 'level': 3, 'y': 11},
        {'name': '│   │   │   ├── 📄 home.dart', 'level': 4, 'y': 10.5},
        {'name': '│   │   │   └── 📄 create_consignment.dart', 'level': 4, 'y': 10},
        {'name': '│   │   └── 📁 driver/', 'level': 3, 'y': 9.5},
        {'name': '│   │       ├── 📄 dashboard.dart', 'level': 4, 'y': 9},
        {'name': '│   │       └── 📄 tracking.dart', 'level': 4, 'y': 8.5},
        {'name': '│   ├── 📁 widgets/', 'level': 2, 'y': 8},
        {'name': '│   │   ├── 📄 custom_button.dart', 'level': 3, 'y': 7.5},
        {'name': '│   │   ├── 📄 map_widget.dart', 'level': 3, 'y': 7},
        {'name': '│   │   └── 📄 chat_widget.dart', 'level': 3, 'y': 6.5},
        {'name': '│   ├── 📁 utils/', 'level': 2, 'y': 6},
        {'name': '│   │   ├── 📄 constants.dart', 'level': 3, 'y': 5.5},
        {'name': '│   │   └── 📄 helpers.dart', 'level': 3, 'y': 5},
        {'name': '│   └── 📄 main.dart', 'level': 2, 'y': 4.5},
        {'name': '├── 📁 assets/', 'level': 1, 'y': 4},
        {'name': '│   ├── 📁 images/', 'level': 2, 'y': 3.5},
        {'name': '│   └── 📁 icons/', 'level': 2, 'y': 3},
        {'name': '├── 📁 test/', 'level': 1, 'y': 2.5},
        {'name': '├── 📄 pubspec.yaml', 'level': 1, 'y': 2},
        {'name': '├── 📄 README.md', 'level': 1, 'y': 1.5},
        {'name': '└── 📄 .env', 'level': 1, 'y': 1}
    ]
    
    # Draw file structure
    for item in structure:
        x_pos = 0.5 + item['level'] * 0.5
        ax.text(x_pos, item['y'], item['name'], fontsize=10, 
               fontfamily='monospace', va='center')
        
        # Add description boxes for important files
        if item['name'].endswith('.dart') and item['level'] <= 3:
            descriptions = {
                'user.dart': 'User data model',
                'consignment.dart': 'Delivery order model',
                'auth_service.dart': 'Authentication logic',
                'main.dart': 'App entry point',
                'dashboard.dart': 'Main dashboard UI',
                'home.dart': 'User home screen'
            }
            
            filename = item['name'].split('📄 ')[-1] if '📄' in item['name'] else ''
            if filename in descriptions:
                desc_box = FancyBboxPatch((x_pos + 2, item['y'] - 0.15), 2.5, 0.3,
                                         boxstyle="round,pad=0.05", 
                                         facecolor='lightyellow', 
                                         edgecolor='orange', alpha=0.7)
                ax.add_patch(desc_box)
                ax.text(x_pos + 3.25, item['y'], descriptions[filename], 
                       fontsize=8, ha='center', va='center', style='italic')
    
    plt.tight_layout()
    plt.savefig('file_structure.png', dpi=300, bbox_inches='tight')
    plt.show()

# 8. SYSTEM FLOW FOR NON-PROGRAMMERS
def create_system_flow_simple():
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(6, 9.5, 'How the Logistics System Works - Simple Overview', 
            fontsize=18, fontweight='bold', ha='center')
    
    # Step-by-step process
    steps = [
        {'step': 1, 'title': 'Client Creates Order', 'pos': (1, 8), 'color': '#3498db',
         'description': 'Customer fills form\nwith pickup & delivery\ndetails'},
        {'step': 2, 'title': 'Admin Reviews', 'pos': (4, 8), 'color': '#e74c3c',
         'description': 'Admin checks order\nand assigns to\navailable driver'},
        {'step': 3, 'title': 'Driver Accepts', 'pos': (7, 8), 'color': '#2ecc71',
         'description': 'Driver receives\nnotification and\naccepts the job'},
        {'step': 4, 'title': 'Pickup & Delivery', 'pos': (10, 8), 'color': '#f39c12',
         'description': 'Driver picks up item\nand delivers to\ndestination'},
        {'step': 5, 'title': 'Real-time Tracking', 'pos': (2.5, 5), 'color': '#9b59b6',
         'description': 'GPS tracking shows\nlive location to\nclient and admin'},
        {'step': 6, 'title': 'Communication', 'pos': (6, 5), 'color': '#1abc9c',
         'description': 'Messages between\nclient, driver,\nand admin'},
        {'step': 7, 'title': 'Completion', 'pos': (9.5, 5), 'color': '#34495e',
         'description': 'Delivery confirmed\nand payment\nprocessed'}
    ]
    
    # Draw steps
    for step in steps:
        # Circle for step number
        circle = Circle(step['pos'], 0.4, facecolor=step['color'], alpha=0.8)
        ax.add_patch(circle)
        ax.text(step['pos'][0], step['pos'][1], str(step['step']), 
                ha='center', va='center', fontsize=16, fontweight='bold', color='white')
        
        # Title
        ax.text(step['pos'][0], step['pos'][1] - 0.7, step['title'], 
                ha='center', va='center', fontsize=12, fontweight='bold')
        
        # Description box
        desc_box = FancyBboxPatch((step['pos'][0] - 0.8, step['pos'][1] - 1.8), 1.6, 0.8,
                                 boxstyle="round,pad=0.1", 
                                 facecolor=step['color'], alpha=0.2,
                                 edgecolor=step['color'], linewidth=1)
        ax.add_patch(desc_box)
        ax.text(step['pos'][0], step['pos'][1] - 1.4, step['description'], 
                ha='center', va='center', fontsize=9)
    
    # Draw arrows between steps
    arrows = [
        ((1.4, 8), (3.6, 8)),    # 1 to 2
        ((4.4, 8), (6.6, 8)),    # 2 to 3
        ((7.4, 8), (9.6, 8)),    # 3 to 4
        ((2.5, 7.6), (2.5, 5.4)), # 4 to 5 (down)
        ((2.9, 5), (5.6, 5)),    # 5 to 6
        ((6.4, 5), (9.1, 5)),    # 6 to 7
    ]
    
    for start, end in arrows:
        arrow = ConnectionPatch(start, end, "data", "data",
                                                              arrowstyle="->", shrinkA=5, shrinkB=5,
                               mutation_scale=20, fc="gray", lw=2)
        ax.add_patch(arrow)
    
    # Add key benefits box
    benefits_box = FancyBboxPatch((0.5, 1.5), 11, 1.5,
                                 boxstyle="round,pad=0.2", 
                                 facecolor='lightgreen', alpha=0.3,
                                 edgecolor='green', linewidth=2)
    ax.add_patch(benefits_box)
    ax.text(6, 2.7, 'Key Benefits', ha='center', va='center', 
            fontsize=14, fontweight='bold')
    ax.text(6, 2, '• Real-time tracking for transparency  • Automated notifications  • Secure messaging\n• Efficient route planning  • Digital record keeping  • 24/7 system availability', 
            ha='center', va='center', fontsize=11)
    
    plt.tight_layout()
    plt.savefig('system_flow_simple.png', dpi=300, bbox_inches='tight')
    plt.show()

# 9. DATA FLOW DIAGRAM
def create_data_flow_diagram():
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(6, 9.5, 'Data Flow in Logistics Management System', 
            fontsize=18, fontweight='bold', ha='center')
    
    # External entities (squares)
    entities = [
        {'name': 'Client', 'pos': (1, 8), 'color': '#3498db'},
        {'name': 'Driver', 'pos': (1, 2), 'color': '#2ecc71'},
        {'name': 'Admin', 'pos': (11, 5), 'color': '#e74c3c'}
    ]
    
    for entity in entities:
        rect = Rectangle((entity['pos'][0] - 0.5, entity['pos'][1] - 0.3), 1, 0.6,
                        facecolor=entity['color'], alpha=0.7, edgecolor='black')
        ax.add_patch(rect)
        ax.text(entity['pos'][0], entity['pos'][1], entity['name'], 
                ha='center', va='center', fontweight='bold', color='white')
    
    # Processes (circles)
    processes = [
        {'name': 'Order\nProcessing', 'pos': (4, 7), 'id': 'P1'},
        {'name': 'Driver\nAssignment', 'pos': (6, 8), 'id': 'P2'},
        {'name': 'Location\nTracking', 'pos': (4, 3), 'id': 'P3'},
        {'name': 'Message\nHandling', 'pos': (8, 5), 'id': 'P4'},
        {'name': 'Status\nUpdates', 'pos': (6, 2), 'id': 'P5'}
    ]
    
    for process in processes:
        circle = Circle(process['pos'], 0.6, facecolor='lightyellow', 
                       edgecolor='orange', linewidth=2)
        ax.add_patch(circle)
        ax.text(process['pos'][0], process['pos'][1] + 0.1, process['id'], 
                ha='center', va='center', fontweight='bold', fontsize=10)
        ax.text(process['pos'][0], process['pos'][1] - 0.2, process['name'], 
                ha='center', va='center', fontsize=8)
    
    # Data stores (open rectangles)
    stores = [
        {'name': 'User Database', 'pos': (9, 8)},
        {'name': 'Consignment DB', 'pos': (9, 6.5)},
        {'name': 'Location Logs', 'pos': (9, 3)},
        {'name': 'Message Store', 'pos': (9, 1.5)}
    ]
    
    for store in stores:
        # Draw open rectangle (data store symbol)
        ax.plot([store['pos'][0] - 0.8, store['pos'][0] + 0.8], 
                [store['pos'][1] + 0.2, store['pos'][1] + 0.2], 'k-', linewidth=2)
        ax.plot([store['pos'][0] - 0.8, store['pos'][0] + 0.8], 
                [store['pos'][1] - 0.2, store['pos'][1] - 0.2], 'k-', linewidth=2)
        ax.plot([store['pos'][0] - 0.8, store['pos'][0] - 0.8], 
                [store['pos'][1] - 0.2, store['pos'][1] + 0.2], 'k-', linewidth=2)
        ax.text(store['pos'][0], store['pos'][1], store['name'], 
                ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Data flows (arrows with labels)
    flows = [
        {'from': (1.5, 8), 'to': (3.4, 7.3), 'label': 'Order Details'},
        {'from': (4.6, 7.3), 'to': (5.4, 7.7), 'label': 'Assignment Request'},
        {'from': (6.6, 8), 'to': (8.2, 8), 'label': 'Driver Info'},
        {'from': (1.5, 2), 'to': (3.4, 2.7), 'label': 'GPS Data'},
        {'from': (4.6, 3), 'to': (5.4, 2.3), 'label': 'Location Update'},
        {'from': (6.6, 2), 'to': (8.2, 3), 'label': 'Status Info'},
        {'from': (8.6, 5), 'to': (10.5, 5), 'label': 'Reports'},
        {'from': (7.4, 5), 'to': (8.2, 1.5), 'label': 'Messages'}
    ]
    
    for flow in flows:
        arrow = ConnectionPatch(flow['from'], flow['to'], "data", "data",
                               arrowstyle="->", shrinkA=5, shrinkB=5,
                               mutation_scale=15, fc="blue", lw=1.5)
        ax.add_patch(arrow)
        
        # Add label
        mid_x = (flow['from'][0] + flow['to'][0]) / 2
        mid_y = (flow['from'][1] + flow['to'][1]) / 2
        ax.text(mid_x, mid_y + 0.2, flow['label'], ha='center', va='center', 
                fontsize=8, bbox=dict(boxstyle="round,pad=0.2", facecolor='white', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('data_flow_diagram.png', dpi=300, bbox_inches='tight')
    plt.show()

# 10. DEPLOYMENT ARCHITECTURE
def create_deployment_architecture():
    fig, ax = plt.subplots(1, 1, figsize=(16, 10))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(7, 9.5, 'System Deployment Architecture', 
            fontsize=18, fontweight='bold', ha='center')
    
    # Cloud infrastructure
    cloud_box = FancyBboxPatch((1, 6), 12, 2.5,
                               boxstyle="round,pad=0.2", 
                               facecolor='lightblue', alpha=0.3,
                               edgecolor='blue', linewidth=2)
    ax.add_patch(cloud_box)
    ax.text(7, 8.2, '☁️ Cloud Infrastructure (Supabase)', 
            ha='center', va='center', fontsize=14, fontweight='bold')
    
    # Cloud components
    cloud_components = [
        {'name': 'Authentication\nService', 'pos': (2.5, 7), 'color': '#e74c3c'},
        {'name': 'PostgreSQL\nDatabase', 'pos': (5, 7), 'color': '#3498db'},
        {'name': 'File Storage\n(Images)', 'pos': (7.5, 7), 'color': '#f39c12'},
        {'name': 'Real-time\nSubscriptions', 'pos': (10, 7), 'color': '#2ecc71'},
        {'name': 'API\nGateway', 'pos': (12, 7), 'color': '#9b59b6'}
    ]
    
    for comp in cloud_components:
        box = FancyBboxPatch((comp['pos'][0] - 0.6, comp['pos'][1] - 0.4), 1.2, 0.8,
                             boxstyle="round,pad=0.1", 
                             facecolor=comp['color'], alpha=0.7,
                             edgecolor='black', linewidth=1)
        ax.add_patch(box)
        ax.text(comp['pos'][0], comp['pos'][1], comp['name'], 
                ha='center', va='center', fontsize=9, fontweight='bold', color='white')
    
    # Mobile devices
    mobile_box = FancyBboxPatch((1, 3.5), 5, 1.5,
                               boxstyle="round,pad=0.2", 
                               facecolor='lightgreen', alpha=0.3,
                               edgecolor='green', linewidth=2)
    ax.add_patch(mobile_box)
    ax.text(3.5, 4.7, '📱 Mobile Applications', 
            ha='center', va='center', fontsize=12, fontweight='bold')
    
    mobile_apps = [
        {'name': 'Admin\nApp', 'pos': (2, 4), 'color': '#e74c3c'},
        {'name': 'Client\nApp', 'pos': (3.5, 4), 'color': '#3498db'},
        {'name': 'Driver\nApp', 'pos': (5, 4), 'color': '#2ecc71'}
    ]
    
    for app in mobile_apps:
        phone = Rectangle((app['pos'][0] - 0.3, app['pos'][1] - 0.4), 0.6, 0.8,
                         facecolor=app['color'], alpha=0.7, edgecolor='black')
        ax.add_patch(phone)
        ax.text(app['pos'][0], app['pos'][1] - 0.8, app['name'], 
                ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Web dashboard
    web_box = FancyBboxPatch((8, 3.5), 5, 1.5,
                            boxstyle="round,pad=0.2", 
                            facecolor='lightyellow', alpha=0.3,
                            edgecolor='orange', linewidth=2)
    ax.add_patch(web_box)
    ax.text(10.5, 4.7, '💻 Web Dashboard', 
            ha='center', va='center', fontsize=12, fontweight='bold')
    
    web_comp = Rectangle((10, 3.8), 1, 0.6, facecolor='orange', alpha=0.7, edgecolor='black')
    ax.add_patch(web_comp)
    ax.text(10.5, 4.1, 'Admin\nPanel', ha='center', va='center', 
            fontsize=9, fontweight='bold', color='white')
    
    # External services
    external_box = FancyBboxPatch((1, 1), 12, 1.5,
                                 boxstyle="round,pad=0.2", 
                                 facecolor='lightcoral', alpha=0.3,
                                 edgecolor='red', linewidth=2)
    ax.add_patch(external_box)
    ax.text(7, 2.2, '🌐 External Services', 
            ha='center', va='center', fontsize=12, fontweight='bold')
    
    external_services = [
        {'name': 'Google Maps\nAPI', 'pos': (3, 1.5), 'color': '#4285f4'},
        {'name': 'Firebase\nNotifications', 'pos': (6, 1.5), 'color': '#ff9800'},
        {'name': 'Payment\nGateway', 'pos': (9, 1.5), 'color': '#4caf50'},
        {'name': 'SMS\nService', 'pos': (11.5, 1.5), 'color': '#9c27b0'}
    ]
    
    for service in external_services:
        box = FancyBboxPatch((service['pos'][0] - 0.5, service['pos'][1] - 0.3), 1, 0.6,
                             boxstyle="round,pad=0.1", 
                             facecolor=service['color'], alpha=0.7,
                             edgecolor='black', linewidth=1)
        ax.add_patch(box)
        ax.text(service['pos'][0], service['pos'][1], service['name'], 
                ha='center', va='center', fontsize=8, fontweight='bold', color='white')
    
    # Connection arrows
    connections = [
        # Mobile to cloud
        ((3.5, 5), (7, 6)),
        # Web to cloud
        ((10.5, 5), (7, 6)),
        # Cloud to external
        ((7, 6), (7, 2.5))
    ]
    
    for start, end in connections:
        arrow = ConnectionPatch(start, end, "data", "data",
                               arrowstyle="<->", shrinkA=5, shrinkB=5,
                               mutation_scale=20, fc="black", lw=2)
        ax.add_patch(arrow)
    
    plt.tight_layout()
    plt.savefig('deployment_architecture.png', dpi=300, bbox_inches='tight')
    plt.show()
def create_database_schema():
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Title
    ax.text(8, 11.5, 'Database Schema - Logistics Management System', 
            fontsize=18, fontweight='bold', ha='center')
    
    # Define tables with their fields
    tables = [
        {
            'name': 'users',
            'pos': (2, 9),
            'fields': [
                'id (PK)',
                'email',
                'password_hash',
                'full_name',
                'phone',
                'role (admin/client/driver)',
                'is_active',
                'created_at',
                'updated_at'
            ],
            'color': '#3498db'
        },
        {
            'name': 'consignments',
            'pos': (8, 9),
            'fields': [
                'id (PK)',
                'client_id (FK)',
                'driver_id (FK)',
                'pickup_location',
                'delivery_location',
                'item_description',
                'weight',
                'status',
                'special_instructions',
                'created_at',
                'updated_at'
            ],
            'color': '#e74c3c'
        },
        {
            'name': 'drivers',
            'pos': (14, 9),
            'fields': [
                'id (PK)',
                'user_id (FK)',
                'license_number',
                'vehicle_type',
                'vehicle_number',
                'is_available',
                'current_location',
                'fuel_card_balance',
                'rating'
            ],
            'color': '#2ecc71'
        },
        {
            'name': 'messages',
            'pos': (2, 5),
            'fields': [
                'id (PK)',
                'consignment_id (FK)',
                'sender_id (FK)',
                'receiver_id (FK)',
                'message_text',
                'message_type',
                'is_read',
                'sent_at'
            ],
            'color': '#f39c12'
        },
        {
            'name': 'tracking_logs',
            'pos': (8, 5),
            'fields': [
                'id (PK)',
                'consignment_id (FK)',
                'driver_id (FK)',
                'latitude',
                'longitude',
                'status',
                'timestamp',
                'notes'
            ],
            'color': '#9b59b6'
        },
        {
            'name': 'fuel_transactions',
            'pos': (14, 5),
            'fields': [
                'id (PK)',
                'driver_id (FK)',
                'amount',
                'location',
                'transaction_type',
                'balance_before',
                'balance_after',
                'created_at'
            ],
            'color': '#1abc9c'
        },
        {
            'name': 'notifications',
            'pos': (2, 1),
            'fields': [
                'id (PK)',
                'user_id (FK)',
                'title',
                'message',
                'type',
                'is_read',
                'created_at'
            ],
            'color': '#e67e22'
        },
        {
            'name': 'system_logs',
            'pos': (8, 1),
            'fields': [
                'id (PK)',
                'user_id (FK)',
                'action',
                'table_name',
                'record_id',
                'old_values',
                'new_values',
                'timestamp'
            ],
            'color': '#95a5a6'
        },
        {
            'name': 'app_settings',
            'pos': (14, 1),
            'fields': [
                'id (PK)',
                'setting_key',
                'setting_value',
                'description',
                'is_active',
                'updated_at'
            ],
            'color': '#34495e'
        }
    ]
    
    # Draw tables
    for table in tables:
        # Calculate table height based on number of fields
        table_height = len(table['fields']) * 0.25 + 0.5
        
        # Table header
        header_rect = Rectangle((table['pos'][0] - 1, table['pos'][1]), 2, 0.4,
                               facecolor=table['color'], edgecolor='black', linewidth=2)
        ax.add_patch(header_rect)
        ax.text(table['pos'][0], table['pos'][1] + 0.2, table['name'].upper(), 
                ha='center', va='center', fontweight='bold', color='white', fontsize=10)
        
        # Table body
        body_rect = Rectangle((table['pos'][0] - 1, table['pos'][1] - table_height), 2, table_height,
                             facecolor='white', edgecolor='black', linewidth=1)
        ax.add_patch(body_rect)
        
        # Table fields
        for i, field in enumerate(table['fields']):
            y_pos = table['pos'][1] - 0.3 - (i * 0.25)
            
            # Highlight primary keys and foreign keys
            if '(PK)' in field:
                field_color = 'gold'
                field_weight = 'bold'
            elif '(FK)' in field:
                field_color = 'lightblue'
                field_weight = 'bold'
            else:
                field_color = 'white'
                field_weight = 'normal'
            
            # Field background
            field_rect = Rectangle((table['pos'][0] - 0.95, y_pos - 0.1), 1.9, 0.2,
                                  facecolor=field_color, alpha=0.7, edgecolor='gray', linewidth=0.5)
            ax.add_patch(field_rect)
            
            ax.text(table['pos'][0], y_pos, field, ha='center', va='center', 
                   fontsize=8, fontweight=field_weight)
    
    # Draw relationships
    relationships = [
        # From users to consignments (client_id)
        {'from': (3, 8.5), 'to': (7, 8.5), 'label': '1:N (client)'},
        # From drivers to consignments (driver_id)
        {'from': (13, 8.5), 'to': (9, 8.5), 'label': '1:N (assigned)'},
        # From users to drivers
        {'from': (3, 9), 'to': (13, 9), 'label': '1:1'},
        # From consignments to messages
        {'from': (7, 7.5), 'to': (3, 6), 'label': '1:N'},
        # From consignments to tracking_logs
        {'from': (8, 7.5), 'to': (8, 6.5), 'label': '1:N'},
        # From drivers to fuel_transactions
        {'from': (14, 7.5), 'to': (14, 6.5), 'label': '1:N'},
        # From users to notifications
        {'from': (2, 7.5), 'to': (2, 2.5), 'label': '1:N'},
        # From users to system_logs
        {'from': (3, 7.5), 'to': (7, 2.5), 'label': '1:N'}
    ]
    
    for rel in relationships:
        # Draw relationship line
        arrow = ConnectionPatch(rel['from'], rel['to'], "data", "data",
                               arrowstyle="->", shrinkA=5, shrinkB=5,
                               mutation_scale=15, fc="red", ec="red", lw=1.5)
        ax.add_patch(arrow)
        
        # Add relationship label
        mid_x = (rel['from'][0] + rel['to'][0]) / 2
        mid_y = (rel['from'][1] + rel['to'][1]) / 2
        ax.text(mid_x, mid_y, rel['label'], ha='center', va='center', 
               fontsize=8, bbox=dict(boxstyle="round,pad=0.2", 
               facecolor='yellow', alpha=0.8), fontweight='bold')
    
    # Add legend
    legend_elements = [
        {'color': 'gold', 'label': 'Primary Key (PK)'},
        {'color': 'lightblue', 'label': 'Foreign Key (FK)'},
        {'color': 'red', 'label': 'Relationship'}
    ]
    
    legend_y = 0.5
    for i, element in enumerate(legend_elements):
        legend_rect = Rectangle((0.5, legend_y - i*0.3), 0.3, 0.2,
                               facecolor=element['color'], alpha=0.7, edgecolor='black')
        ax.add_patch(legend_rect)
        ax.text(1, legend_y - i*0.3 + 0.1, element['label'], 
               ha='left', va='center', fontsize=10, fontweight='bold')
    
    # Add database info box
    info_box = FancyBboxPatch((10, 0.2), 5.5, 1.5,
                             boxstyle="round,pad=0.2", 
                             facecolor='lightgray', alpha=0.8,
                             edgecolor='black', linewidth=2)
    ax.add_patch(info_box)
    ax.text(12.75, 1.2, 'Database Information', ha='center', va='center', 
           fontsize=12, fontweight='bold')
    ax.text(12.75, 0.8, 'Engine: PostgreSQL (Supabase)\nCharset: UTF-8\nTimezone: UTC', 
           ha='center', va='center', fontsize=10)
    
    plt.tight_layout()
    plt.savefig('database_schema.png', dpi=300, bbox_inches='tight')
    plt.show()

# 11. USER MANUAL DIAGRAM
def create_user_manual():
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    fig.suptitle('User Manual - Quick Start Guide', fontsize=20, fontweight='bold')
    
    # Admin Guide
    ax1 = axes[0, 0]
    ax1.set_xlim(0, 10)
    ax1.set_ylim(0, 10)
    ax1.set_title('Admin User Guide', fontsize=14, fontweight='bold', color='red')
    
    admin_steps = [
        {'step': '1', 'text': 'Login with admin credentials', 'y': 9},
        {'step': '2', 'text': 'View dashboard overview', 'y': 8},
        {'step': '3', 'text': 'Manage user accounts', 'y': 7},
        {'step': '4', 'text': 'Review and assign consignments', 'y': 6},
        {'step': '5', 'text': 'Monitor real-time tracking', 'y': 5},
        {'step': '6', 'text': 'Generate reports and analytics', 'y': 4},
        {'step': '7', 'text': 'Handle system settings', 'y': 3}
    ]
    
    for step in admin_steps:
        # Step circle
        circle = Circle((1, step['y']), 0.3, facecolor='red', alpha=0.7)
        ax1.add_patch(circle)
        ax1.text(1, step['y'], step['step'], ha='center', va='center', 
                fontweight='bold', color='white')
        # Step text
        ax1.text(1.8, step['y'], step['text'], ha='left', va='center', fontsize=10)
        # Arrow to next step
        if step['y'] > 3:
            ax1.arrow(1, step['y']-0.4, 0, -0.2, head_width=0.1, head_length=0.1, 
                     fc='red', ec='red')
    
    ax1.axis('off')
    
    # Client Guide
    ax2 = axes[0, 1]
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 10)
    ax2.set_title('Client User Guide', fontsize=14, fontweight='bold', color='blue')
    
    client_steps = [
        {'step': '1', 'text': 'Register and login', 'y': 9},
        {'step': '2', 'text': 'Create new consignment', 'y': 8},
        {'step': '3', 'text': 'Fill pickup and delivery details', 'y': 7},
        {'step': '4', 'text': 'Submit request and wait for approval', 'y': 6},
        {'step': '5', 'text': 'Track delivery in real-time', 'y': 5},
        {'step': '6', 'text': 'Communicate with driver', 'y': 4},
        {'step': '7', 'text': 'Confirm delivery completion', 'y': 3}
    ]
    
    for step in client_steps:
        circle = Circle((1, step['y']), 0.3, facecolor='blue', alpha=0.7)
        ax2.add_patch(circle)
        ax2.text(1, step['y'], step['step'], ha='center', va='center', 
                fontweight='bold', color='white')
        ax2.text(1.8, step['y'], step['text'], ha='left', va='center', fontsize=10)
        if step['y'] > 3:
            ax2.arrow(1, step['y']-0.4, 0, -0.2, head_width=0.1, head_length=0.1, 
                     fc='blue', ec='blue')
    
    ax2.axis('off')
    
    # Driver Guide
    ax3 = axes[1, 0]
    ax3.set_xlim(0, 10)
    ax3.set_ylim(0, 10)
    ax3.set_title('Driver User Guide', fontsize=14, fontweight='bold', color='green')
    
    driver_steps = [
        {'step': '1', 'text': 'Login to driver app', 'y': 9},
        {'step': '2', 'text': 'View assigned consignments', 'y': 8},
        {'step': '3', 'text': 'Accept delivery job', 'y': 7},
        {'step': '4', 'text': 'Navigate to pickup location', 'y': 6},
        {'step': '5', 'text': 'Start GPS tracking', 'y': 5},
        {'step': '6', 'text': 'Update delivery status', 'y': 4},
        {'step': '7', 'text': 'Confirm completion', 'y': 3}
    ]
    
    for step in driver_steps:
        circle = Circle((1, step['y']), 0.3, facecolor='green', alpha=0.7)
        ax3.add_patch(circle)
        ax3.text(1, step['y'], step['step'], ha='center', va='center', 
                fontweight='bold', color='white')
        ax3.text(1.8, step['y'], step['text'], ha='left', va='center', fontsize=10)
        if step['y'] > 3:
            ax3.arrow(1, step['y']-0.4, 0, -0.2, head_width=0.1, head_length=0.1, 
                     fc='green', ec='green')
    
    ax3.axis('off')
    
    # Common Features Guide
    ax4 = axes[1, 1]
    ax4.set_xlim(0, 10)
    ax4.set_ylim(0, 10)
    ax4.set_title('Common Features', fontsize=14, fontweight='bold', color='purple')
    
    common_features = [
        {'icon': '💬', 'text': 'In-app messaging', 'y': 8.5},
        {'icon': '📍', 'text': 'Real-time GPS tracking', 'y': 7.5},
        {'icon': '🔔', 'text': 'Push notifications', 'y': 6.5},
        {'icon': '📷', 'text': 'Photo sharing', 'y': 5.5},
        {'icon': '📊', 'text': 'Status updates', 'y': 4.5},
        {'icon': '🔒', 'text': 'Secure authentication', 'y': 3.5}
    ]
    
    for feature in common_features:
        ax4.text(1, feature['y'], feature['icon'], ha='center', va='center', fontsize=20)
        ax4.text(2, feature['y'], feature['text'], ha='left', va='center', fontsize=11)
    
    ax4.axis('off')
    
    plt.tight_layout()
    plt.savefig('user_manual.png', dpi=300, bbox_inches='tight')
    plt.show()

# 12. COMMUNICATION FLOW DIAGRAM
def create_communication_flow():
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(6, 9.5, 'Communication Flow Between System Users', 
            fontsize=18, fontweight='bold', ha='center')
    
    # User positions
    users = [
        {'name': 'Admin', 'pos': (2, 7), 'color': '#e74c3c'},
        {'name': 'Client', 'pos': (6, 8.5), 'color': '#3498db'},
        {'name': 'Driver', 'pos': (10, 7), 'color': '#2ecc71'},
        {'name': 'System', 'pos': (6, 5), 'color': '#f39c12'}
    ]
    
    # Draw users
    for user in users:
        if user['name'] == 'System':
            # System as rectangle
            rect = Rectangle((user['pos'][0] - 0.8, user['pos'][1] - 0.4), 1.6, 0.8,
                           facecolor=user['color'], alpha=0.7, edgecolor='black')
            ax.add_patch(rect)
        else:
            # Users as circles
            circle = Circle(user['pos'], 0.6, facecolor=user['color'], alpha=0.7)
            ax.add_patch(circle)
        
        ax.text(user['pos'][0], user['pos'][1], user['name'], 
                ha='center', va='center', fontweight='bold', color='white')
    
    # Communication channels
    communications = [
        {'from': (2, 7), 'to': (6, 8.5), 'label': 'Order Assignment\nNotifications', 'color': 'red'},
        {'from': (6, 8.5), 'to': (10, 7), 'label': 'Delivery Instructions\nLocation Sharing', 'color': 'blue'},
        {'from': (10, 7), 'to': (2, 7), 'label': 'Status Updates\nDelivery Reports', 'color': 'green'},
        {'from': (6, 5), 'to': (2, 7), 'label': 'System Alerts\nAnalytics', 'color': 'orange'},
        {'from': (6, 5), 'to': (6, 8.5), 'label': 'Order Confirmations\nTracking Updates', 'color': 'orange'},
        {'from': (6, 5), 'to': (10, 7), 'label': 'Job Assignments\nRoute Optimization', 'color': 'orange'}
    ]
    
    # Draw communication lines
    for comm in communications:
        # Curved arrow
        arrow = ConnectionPatch(comm['from'], comm['to'], "data", "data",
                               arrowstyle="<->", shrinkA=30, shrinkB=30,
                               mutation_scale=15, fc=comm['color'], 
                               ec=comm['color'], lw=2, alpha=0.7,
                               connectionstyle="arc3,rad=0.2")
        ax.add_patch(arrow)
        
        # Label
        mid_x = (comm['from'][0] + comm['to'][0]) / 2
        mid_y = (comm['from'][1] + comm['to'][1]) / 2 + 0.3
        ax.text(mid_x, mid_y, comm['label'], ha='center', va='center', 
                fontsize=8, bbox=dict(boxstyle="round,pad=0.2", 
                facecolor='white', alpha=0.8, edgecolor=comm['color']))
    
    # Communication types legend
    legend_box = FancyBboxPatch((0.5, 1), 11, 2,
                               boxstyle="round,pad=0.2", 
                               facecolor='lightgray', alpha=0.3,
                               edgecolor='black', linewidth=1)
    ax.add_patch(legend_box)
    ax.text(6, 2.5, 'Communication Types', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    comm_types = [
        '📱 Push Notifications', '💬 In-App Messaging', '📧 Email Alerts',
        '📍 Location Updates', '📊 Status Reports', '🔔 System Notifications'
    ]
    
    for i, comm_type in enumerate(comm_types):
        x = 1.5 + (i % 3) * 3.5
        y = 2 - (i // 3) * 0.4
        ax.text(x, y, comm_type, ha='left', va='center', fontsize=10)
    
    plt.tight_layout()
    plt.savefig('communication_flow.png', dpi=300, bbox_inches='tight')
    plt.show()

# 13. SYSTEM LIFECYCLE DIAGRAM
def create_system_lifecycle():
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(6, 9.5, 'Complete System Lifecycle - From Order to Delivery', 
            fontsize=16, fontweight='bold', ha='center')
    
    # Lifecycle stages
    stages = [
        {'name': 'Order\nCreation', 'pos': (2, 8), 'color': '#3498db', 'time': '0 min'},
        {'name': 'Admin\nReview', 'pos': (4, 8), 'color': '#e74c3c', 'time': '5-15 min'},
        {'name': 'Driver\nAssignment', 'pos': (6, 8), 'color': '#f39c12', 'time': '15-30 min'},
        {'name': 'Pickup\nScheduled', 'pos': (8, 8), 'color': '#9b59b6', 'time': '30-60 min'},
        {'name': 'Item\nPickup', 'pos': (10, 8), 'color': '#2ecc71', 'time': '1-2 hours'},
        {'name': 'In\nTransit', 'pos': (10, 6), 'color': '#1abc9c', 'time': '2-8 hours'},
        {'name': 'Delivery\nAttempt', 'pos': (8, 6), 'color': '#e67e22', 'time': '4-12 hours'},
        {'name': 'Delivery\nComplete', 'pos': (6, 6), 'color': '#27ae60', 'time': '4-12 hours'},
        {'name': 'Payment\nProcessed', 'pos': (4, 6), 'color': '#8e44ad', 'time': '12-24 hours'},
        {'name': 'Order\nClosed', 'pos': (2, 6), 'color': '#34495e', 'time': '24-48 hours'}
    ]
    
    # Draw stages
    for i, stage in enumerate(stages):
        # Stage circle
        circle = Circle(stage['pos'], 0.5, facecolor=stage['color'], alpha=0.8)
        ax.add_patch(circle)
        ax.text(stage['pos'][0], stage['pos'][1], stage['name'], 
                ha='center', va='center', fontweight='bold', color='white', fontsize=9)
        
        # Time indicator
        ax.text(stage['pos'][0], stage['pos'][1] - 0.8, stage['time'], 
                ha='center', va='center', fontsize=8, style='italic',
                bbox=dict(boxstyle="round,pad=0.2", facecolor='lightyellow'))
        
        # Connect to next stage
        if i < len(stages) - 1:
            next_stage = stages[i + 1]
            arrow = ConnectionPatch(stage['pos'], next_stage['pos'], "data", "data",
                                   arrowstyle="->", shrinkA=25, shrinkB=25,
                                   mutation_scale=20, fc="gray", lw=2)
            ax.add_patch(arrow)
    
    # Status indicators
    status_box = FancyBboxPatch((1, 3.5), 10, 1.5,
                               boxstyle="round,pad=0.2", 
                               facecolor='lightblue', alpha=0.3,
                               edgecolor='blue', linewidth=2)
    ax.add_patch(status_box)
    ax.text(6, 4.7, 'Real-time Status Tracking Available Throughout Process',
            ha='center', va='center', fontsize=12, fontweight='bold')
    
    status_indicators = [
        '🔄 Live Updates', '📍 GPS Tracking', '💬 Communication', 
        '📱 Notifications', '📊 Progress Reports'
    ]
    
    for i, indicator in enumerate(status_indicators):
        x = 2 + i * 2
        ax.text(x, 4.2, indicator, ha='center', va='center', fontsize=10)
    
    # Exception handling
    exception_box = FancyBboxPatch((1, 1.5), 10, 1.5,
                                  boxstyle="round,pad=0.2", 
                                  facecolor='lightcoral', alpha=0.3,
                                  edgecolor='red', linewidth=2)
    ax.add_patch(exception_box)
    ax.text(6, 2.7, 'Exception Handling & Contingencies',
            ha='center', va='center', fontsize=12, fontweight='bold')
    
    exceptions = [
        '❌ Delivery Failed', '🔄 Rescheduling', '📞 Customer Contact', 
        '🚨 Emergency Support', '💰 Refund Process'
    ]
    
    for i, exception in enumerate(exceptions):
        x = 2 + i * 2
        ax.text(x, 2.2, exception, ha='center', va='center', fontsize=10)
    
    plt.tight_layout()
    plt.savefig('system_lifecycle.png', dpi=300, bbox_inches='tight')
    plt.show()

# Execute all visualization functions
if __name__ == "__main__":
    print("Generating comprehensive logistics system documentation...")
    
    # Generate all diagrams
    create_system_architecture()
    print("✅ System Architecture diagram created")
    
    create_database_schema()
    print("✅ Database Schema diagram created")
    
    create_security_architecture()
    print("✅ Security Architecture diagram created")
    
    create_user_privilege_matrix()
    print("✅ User Privilege Matrix created")
    
    create_system_evaluation()
    print("✅ System Evaluation Dashboard created")
    
    create_ui_mockup()
    print("✅ UI Mockup designs created")
    
    create_file_structure()
    print("✅ File Structure diagram created")
    
    create_system_flow_simple()
    print("✅ Simple System Flow created")
    
    create_data_flow_diagram()
    print("✅ Data Flow Diagram created")
    
    create_deployment_architecture()
    print("✅ Deployment Architecture created")
    
    create_user_manual()
    print("✅ User Manual created")
    
    create_communication_flow()
    print("✅ Communication Flow diagram created")
    
    create_system_lifecycle()
    print("✅ System Lifecycle diagram created")
    
    print("\n🎉 All documentation diagrams have been generated successfully!")
    print("📁 Check your current directory for the following PNG files:")
    print("   • system_architecture.png")
    print("   • database_schema.png")
    print("   • security_architecture.png")
    print("   • user_privilege_matrix.png")
    print("   • system_evaluation.png")
    print("   • ui_mockup.png")
    print("   • file_structure.png")
    print("   • system_flow_simple.png")
    print("   • data_flow_diagram.png")
    print("   • deployment_architecture.png")
    print("   • user_manual.png")
    print("   • communication_flow.png")
    print("   • system_lifecycle.png")
    
    # Summary report
    print("\n📋 SYSTEM DOCUMENTATION SUMMARY:")
    print("=" * 50)
    print("🏗️  Architecture: Multi-tier mobile application")
    print("💾 Database: Supabase (PostgreSQL)")
    print("📱 Frontend: Flutter (Cross-platform)")
    print("🔐 Security: Role-based access control")
    print("👥 Users: Admin, Client, Driver")
    print("🌐 Deployment: Cloud-based infrastructure")
    print("📊 Features: Real-time tracking, messaging, analytics")
    print("🔄 Status: Ready for development implementation")
    print("=" * 50)



