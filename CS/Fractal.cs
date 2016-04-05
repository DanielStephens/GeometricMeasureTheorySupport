using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class Fractal{
	public static int divisionLimit = 0;
	int dimension = 3;
	float val = 1f/3f;
	public delegate Mesh MeshMould(Mesh mesh);
	MeshMould mm;
	Mesh this_mesh;
	MeshFilter MF;
	float delta = 0.001f;
	GameObject go;
	static Vector3[] directions = new Vector3[]{Vector3.right, -Vector3.right, Vector3.up, -Vector3.up, Vector3.forward, -Vector3.forward};

	public Fractal(Vector3 domain, MeshFilter mf, GameObject gameObject){
		SetupIteratedFunctions();
		go = gameObject;
		MF = mf;
		this_mesh = MF.mesh;
		MF.mesh = this_mesh;
	}

	public IEnumerator Iterate(){
		if(divisionLimit > 5) yield break;
		yield return null;
		string savedStr = "Mesh"+divisionLimit;
		Mesh savedMesh = (Mesh)Resources.Load(savedStr);
		if(savedMesh != null){
			this_mesh = savedMesh;
			MF.mesh = this_mesh;
			yield break;
		}
		int curVerts = this_mesh.vertices.Length;
		if(curVerts*mm.GetInvocationList().Count() <= 64000){
			var results = mm.GetInvocationList().Select(x => (Mesh)x.DynamicInvoke(Scale(this_mesh, val)));
			yield return null;
			Dictionary<int, int> vertReplace = new Dictionary<int, int>();
			List<Vector3> verts = new List<Vector3>();
			List<Vector3> norms = new List<Vector3>();
			List<int> tris = new List<int>();
			int count = 0;
			foreach(var result in results){
				Mesh m = (Mesh)result;
				for(int i = 0; i < m.vertices.Length; i++){
					int index = ContainsApproximate(m.bounds, verts, norms, m.vertices[i], m.normals[i]);
					if(index == -1){
						vertReplace.Add(count + i, verts.Count);
						verts.Add(m.vertices[i]);
						norms.Add(m.normals[i]);
					}else{
						vertReplace.Add(count + i, index);
					}
				}
				for(int j = 0; j < m.triangles.Length; j++){
					int origIndex = m.triangles[j]+count;
					tris.Add(vertReplace[origIndex]);
				}
				count += m.vertices.Length;
				yield return null;
			}
			this_mesh.Clear();
			this_mesh.vertices = verts.ToArray();
			this_mesh.triangles = tris.ToArray();
			this_mesh.normals = norms.ToArray();
		}else{
			for(int z = 0; z < 3; z++){
				for(int y = 0; y < 3; y++){
					for(int x = 0; x < 3; x++){
						bool b = x == 2 || y == 2 || z == 0;
						if(!b) continue;
						if(!ValidPosition(x,y,z)) continue;
						Vector3 position = go.transform.position + Vector3.Scale(new Vector3(x*val, y*val, z*val), go.transform.localScale);
						Vector3 scale = go.transform.localScale*val;
						GameObject gg = GameObject.Instantiate(go, position, Quaternion.identity) as GameObject;
						gg.transform.localScale = scale;
					}
				}
			}
			GameObject.Destroy(go);
		}
	}

	public int ContainsApproximate(Bounds b, List<Vector3> verts, List<Vector3> norms, Vector3 vs, Vector3 norm){
		if(!OnBounds(b, vs)) return -1;
		for(int i = 0; i < verts.Count; i++){
			if((verts[i]-vs).sqrMagnitude <= delta*delta){
				if((norms[i]-norm).sqrMagnitude < 0.01f){
					return i;
				}
			}
		}
		return -1;
	}

	public bool OnBounds(Bounds b, Vector3 v){
		if(Mathf.Abs(v.x-b.min.x) < delta || Mathf.Abs(v.x-b.max.x) < delta) return true;
		if(Mathf.Abs(v.y-b.min.y) < delta || Mathf.Abs(v.y-b.max.y) < delta) return true;
		if(Mathf.Abs(v.z-b.min.z) < delta || Mathf.Abs(v.z-b.max.z) < delta) return true;
		return false;
	}

	public bool ValidPosition(int x, int y, int z){
		int sum = x == 1 ? 1 : 0;
		sum += y == 1 ? 1 : 0;
		sum += z == 1 ? 1 : 0;
		return sum <= 1;
	}

	public void SetupIteratedFunctions(){
		for(int z = 0; z < 3; z++){
			for(int y = 0; y < 3; y++){
				for(int x = 0; x < 3; x++){
					if(!ValidPosition(x,y,z)) continue;
					List<Vector3> sides = new List<Vector3>();
					for(int off=-1; off<2; off+=2){
						if(ValidPosition(x+off,y,z)) sides.Add(directions[(off+1)/2]);
						if(ValidPosition(x,y+off,z)) sides.Add(directions[2+(off+1)/2]);
						if(ValidPosition(x,y,z+off)) sides.Add(directions[4+(off+1)/2]);
					}
					if(mm == null){
						mm = delegate(Mesh mesh){
							return Transform(RemoveSides(mesh, sides.ToArray()), new Vector3(val*x, val*y, val*z));
						};
					}else{
						mm += delegate(Mesh mesh){
							return Transform(RemoveSides(mesh, sides.ToArray()), new Vector3(val*x, val*y, val*z));
						};
					}
				}
			}
		}
	}

	public Mesh RemoveSides(Mesh mesh, params Vector3[] vs){
		List<Vector3> verts = new List<Vector3>();
		List<Vector3> norms = new List<Vector3>();
		List<int> tris = new List<int>();
		Dictionary<int, int> vertReplace = new Dictionary<int, int>();
		for(int i = 0; i < mesh.vertices.Length; i++){
			bool b = vs.Contains(mesh.normals[i]) && Mathf.Approximately(Vector3.Dot(mesh.normals[i], mesh.vertices[i]-(Vector3.one*val/2f)), val/2f);
			if(!b){
				vertReplace.Add(i, verts.Count);
				verts.Add(mesh.vertices[i]);
				norms.Add(mesh.normals[i]);
			}
		}
		for(int j = 0; j < mesh.triangles.Length; j+=3){
			int k1 = mesh.triangles[j];
			int k2 = mesh.triangles[j+1];
			int k3 = mesh.triangles[j+2];
			if(vertReplace.ContainsKey(k1) && vertReplace.ContainsKey(k2) && vertReplace.ContainsKey(k3)){
				tris.Add(vertReplace[k1]);
				tris.Add(vertReplace[k2]);
				tris.Add(vertReplace[k3]);
			}
		}
		Mesh m = new Mesh();
		m.vertices = verts.ToArray();
		m.triangles = tris.ToArray();
		m.normals = norms.ToArray();
		return m;
	}

	public Mesh Scale(Mesh mesh, float v){
		Vector3[] verts = mesh.vertices;
		for(int i = 0; i < mesh.vertices.Length; i++){
			verts[i] *= v;
		}
		Mesh m = UnityEngine.Object.Instantiate(mesh);
		m.vertices = verts;
		Bounds b = m.bounds;
		b.min = mesh.bounds.min*v;
		b.max = mesh.bounds.max*v;
		m.bounds = b;
		return m;
	}

	public Mesh Transform(Mesh mesh, Vector3 v){
		Vector3[] verts = mesh.vertices;
		for(int i = 0; i < mesh.vertices.Length; i++){
			verts[i] += v;
		}
		mesh.vertices = verts;
		Bounds b = mesh.bounds;
		b.min = mesh.bounds.min+v;
		b.max = mesh.bounds.max+v;
		mesh.bounds = b;
		return mesh;
	}
}